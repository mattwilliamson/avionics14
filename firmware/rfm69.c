/**
 * Radio Driver for RFM69W.
 *
 * External thread calls log function, 16 bytes are allocated in the memory pool for 
 * data, a message is sent to the mailbox, assume data of format:
 * 
 * | Timestamp(4) | Stage + logtype(1) | Channel(1) | Unused(2) | Data(8) |
 * 
 * The radio thread checks the mailbox, if ready, a return message will have a pointer to data
 * Radio transmits data and returns to standby mode.
 * Note: data pointer is cast to uint8* to be compatible with rfm_tx(), this has worked
 * for a similar project I've done with this radio - as long as data is cast back to char
 * at the groundstation.
 *
 * Credit to Joe Desbonnet for the core of the radio driver section
 */

#include <stdint.h>
#include <string.h>
#include "rfm69.h"
#include "err.h" 
#include "hal.h"
#include "config.h"
#include "rfm69_config.h"
#include "tweeter.h"

//change as needed
#define RFM69_SPID SPID3
#define RFM69_SPI_CS_PORT GPIOD
#define RFM69_SPI_CS_PIN GPIOD_RADIO_CS

#define RFM69_MEMPOOL_ITEMS 32

static MemoryPool rfm69_mp;
static volatile char rfm69_mp_b[RFM69_MEMPOOL_ITEMS * 16];

static Mailbox rfm69_mb;
static volatile msg_t rfm69_mb_q[RFM69_MEMPOOL_ITEMS];

static void rfm69_mem_init(void);

void rfm69_send_test_packet(const char* data)
{
    char pkt[16];
    int i;
    for(i=0; i<8; i++) pkt[i] = 0;
    memcpy(pkt+8, data, 8);
    rfm69_log_packet((uint8_t*)pkt);
}

void rfm69_log_packet(uint8_t* packet)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    if(msg == NULL)
        return;
    memcpy(msg, (void*)packet, 16);
    msg_t rv = chMBPost(&rfm69_mb, (intptr_t)msg, TIME_IMMEDIATE);
    if(rv != RDY_OK) {
        chPoolFree(&rfm69_mp, msg);
    }
}

static void rfm69_mem_init()
{
	chPoolInit(&rfm69_mp, 16, NULL);
	chPoolLoadArray(&rfm69_mp, (void*)rfm69_mp_b, RFM69_MEMPOOL_ITEMS);
	chMBInit(&rfm69_mb, (msg_t*)rfm69_mb_q, RFM69_MEMPOOL_ITEMS);
}

/*-----------------Start of RFM69W specific section-----------------------------------*/

/**
 * Wait for a register bit to go high, with timeout.
 */

uint8_t rfm69_spi_transfer_byte(SPIDriver* SPID, uint8_t out) {
	//the spi_transfer_byte function in this library is an SPI exchange: out is sent and MISO is sampled synchronously, so think can be replaced with the CHiBiOS spiExchange method
	uint8_t val; 	
	spiExchange(SPID, 1, &out, &val);
	
	return val;
}

uint8_t rfm69_register_read (SPIDriver* SPID, uint8_t reg_addr) {
	spiSelect(SPID);
	rfm69_spi_transfer_byte(SPID, reg_addr);
	uint8_t reg_value = rfm69_spi_transfer_byte(SPID, 0xff);
	spiUnselect(SPID);
	return reg_value;
}

void rfm69_register_write (SPIDriver* SPID, uint8_t reg_addr, uint8_t reg_value) {
	spiSelect(SPID);
	rfm69_spi_transfer_byte (SPID, reg_addr | 0x80); // Set bit 7 to indicate write op
	rfm69_spi_transfer_byte (SPID, reg_value);
	spiUnselect(SPID);
}

int rfm69_wait_for_bit_high (SPIDriver* SPID, uint8_t reg_addr, uint8_t mask) {
	int niter=30;
	while ( (rfm69_register_read(SPID, reg_addr) & mask) == 0) {
        chThdSleepMilliseconds(60);
		if (--niter == 0) {
            tweeter_set_error(ERROR_RADIO, true);
			return E_TIMEOUT;
		}
	}
    tweeter_set_error(ERROR_RADIO, false);
	return E_OK;
}

/** 
 * Test for presence of RFM69
 */
int rfm69_test (SPIDriver* SPID) {
	// Backup AES key register 1
	int aeskey1 = rfm69_register_read(SPID, 0x3E);

	rfm69_register_write(SPID, 0x3E,0x55);
	if (rfm69_register_read(SPID, 0x3E)!=0x55) {
		return -1;
	}
	rfm69_register_write(SPID, 0x3E,0xAA);
	if (rfm69_register_read(SPID, 0x3E)!=0xAA) {
		return -1;
	}
	// Restore value
	rfm69_register_write(SPID, 0x3E, aeskey1);

	return 0;
}
/**
 * Configure RFM69 radio module for use. Assumes SPI interface is already configured.
 */
void rfm69_config(SPIDriver* SPID) {
	int i;
	for (i = 0; RFM69_CONFIG[i][0] != 255; i++) {
	    rfm69_register_write(SPID, RFM69_CONFIG[i][0], RFM69_CONFIG[i][1]);
	}

	//have 433MHz for bottom stage, 434 MHz for next stage
	if(STAGE == 1) {
		rfm69_register_write(SPID, RFM69_FRFMID, 0x40);
	} else {
		rfm69_register_write(SPID, RFM69_FRFMID, 0x80);
	}
}


/**
 * Set RFM69 operating mode. Use macro values RFM69_OPMODE_Mode_xxxx as arg.
 */
int rfm69_mode (SPIDriver* SPID, uint8_t mode) {
	uint8_t regVal = rfm69_register_read(SPID, RFM69_OPMODE);
	regVal &= ~RFM69_OPMODE_Mode_MASK;
	regVal |= RFM69_OPMODE_Mode_VALUE(mode);
	rfm69_register_write(SPID, RFM69_OPMODE,regVal);

	// Wait until mode change is complete
	// IRQFLAGS1[7] ModeReady: Set to 0 when mode change, 1 when mode change complete
	return rfm69_wait_for_bit_high(SPID, RFM69_IRQFLAGS1, RFM69_IRQFLAGS1_ModeReady);
}

/**
 * Transmit a frame stored in buf
 */
void rfm69_frame_tx(SPIDriver* SPID, uint8_t *buf, int len) {

	// Turn off receiver before writing to FIFO
	rfm69_mode(SPID, RFM69_OPMODE_Mode_STDBY);
	// Write frame to FIFO
	spiSelect(SPID);
	rfm69_spi_transfer_byte(SPID, RFM69_FIFO | 0x80);
	// packet length
	rfm69_spi_transfer_byte(SPID, len);

	int i;
	for (i = 0; i < len; i++) {
		rfm69_spi_transfer_byte(SPID, buf[i]);
	}
	spiUnselect(SPID);

	// Power up TX
	rfm69_mode(SPID, RFM69_OPMODE_Mode_TX);
    // TX packet
	rfm69_wait_for_bit_high(SPID, RFM69_IRQFLAGS2, RFM69_IRQFLAGS2_PacketSent);
    // Back to standby
	rfm69_mode(SPID, RFM69_OPMODE_Mode_STDBY);
}

/*----------------------------Thread-------------------------------------------------*/

msg_t rfm69_thread(void *arg) {
	
	msg_t status;
    intptr_t msgp;
	uint8_t *msg;
    int i;
	
	(void) arg;
	chRegSetThreadName("RFM69");
	
	//setup SPI: CPHA = 0, CPOL = 0;
	const SPIConfig spi_cfg = { 
		NULL,
		RFM69_SPI_CS_PORT,
		RFM69_SPI_CS_PIN,
		SPI_CR1_BR_2 | 0 | 0
	};
	
	spiStart(&RFM69_SPID, &spi_cfg);
	rfm69_config(&RFM69_SPID);
	
	rfm69_mem_init();
	
	
	if(rfm69_test(&RFM69_SPID) == 0) {
		//two blinks to show correct initialisation
		for(i = 0; i<2; i++) {
			palClearPad(GPIOD, GPIOD_RADIO_GRN);
			chThdSleepMilliseconds(500);
			palSetPad(GPIOD, GPIOD_RADIO_GRN);
			chThdSleepMilliseconds(500);
		}
	} else {
		//two blinks red to show incorrect initialisation
        tweeter_set_error(ERROR_RADIO, true);
		for(i = 0; i<2; i++) {
			palClearPad(GPIOD, GPIOD_RADIO_RED);
			chThdSleepMilliseconds(500);
			palSetPad(GPIOA, GPIOD_RADIO_RED);
			chThdSleepMilliseconds(500);
		}
	}

	while(TRUE) {
		status = chMBFetch(&rfm69_mb, (msg_t*)&msgp, TIME_INFINITE);
		if(status != RDY_OK || msgp == 0) {
            chThdSleepMilliseconds(1);
			continue;
		}
		msg = (uint8_t*) msgp;  
	    palSetPad(GPIOD, GPIOD_RADIO_GRN);	
		rfm69_frame_tx(&RFM69_SPID, msg, 16);
	    palClearPad(GPIOD, GPIOD_RADIO_GRN);	
		chPoolFree(&rfm69_mp, (void*)msg);
        chThdSleepMilliseconds(20);
	}
}

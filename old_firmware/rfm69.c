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
#include "rfm69.h"
#include "rfm69_config.h"

#include "err.h" 
#include "hal.h"
#include "config.h"

//change as needed
#define RFM69_SPID SPID1 
#define RFM69_SPI_CS_PORT GPIOD 
#define RFM69_SPI_CS_PIN GPIOD_RADIO_CS

#define RFM69_MEMPOOL_ITEMS 32

static MemoryPool rfm69_mp;
static volatile char rfm69_mp_b[RFM69_MEMPOOL_ITEMS * 16]
					__attribute__((aligned(sizeof(stkalign_t))))
					__attribute__((section(".ccm")));

static Mailbox rfm69_mb;
static volatile msg_t rfm69_mb_q[RFM69_MEMPOOL_ITEMS];

static void rfm69_mem_init(void);

void rfm69_log_c(uint8_t channel, const char* data)
{
    volatile char *msg;
    msg = (char*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(0 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy((void*)msg, (void*)&halGetCounterValue(), 4);
    memcpy((void*)&msg[8], data, 8);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
}

void rfm69_log_s64(uint8_t channel, int64_t data)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(1 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy(msg, (void*)&halGetCounterValue(), 4);
    memcpy(&msg[8], &data, 8);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
}

void rfm69_log_s32(uint8_t channel, int32_t data_a, int32_t data_b)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(3 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy(msg, (void*)&halGetCounterValue(), 4);
    memcpy(&msg[8],  &data_a, 4);
    memcpy(&msg[12], &data_b, 4);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
}

void rfm69_log_s16(uint8_t channel, int16_t data_a, int16_t data_b,
                                      int16_t data_c, int16_t data_d)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(5 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy(msg, (void*)&halGetCounterValue(), 4);
    memcpy(&msg[8],  &data_a, 2);
    memcpy(&msg[10], &data_b, 2);
    memcpy(&msg[12], &data_c, 2);
    memcpy(&msg[14], &data_d, 2);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
}

void rfm69_log_u16(uint8_t channel, uint16_t data_a, uint16_t data_b,
                                      uint16_t data_c, uint16_t data_d)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(6 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy(msg, (void*)&halGetCounterValue(), 4);
    memcpy(&msg[8],  &data_a, 2);
    memcpy(&msg[10], &data_b, 2);
    memcpy(&msg[12], &data_c, 2);
    memcpy(&msg[14], &data_d, 2);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
}

void rfm69_log_f(uint8_t channel, float data_a, float data_b)
{
    char *msg;
    msg = (void*)chPoolAlloc(&rfm69_mp);
    msg[4] = (char)(9 | conf.location << 4);
    msg[5] = (char)channel;
    memcpy(msg, (void*)&halGetCounterValue(), 4);
    memcpy(&msg[8],  &data_a, 4);
    memcpy(&msg[12], &data_b, 4);
    chMBPost(&rfm69_mb, (msg_t)msg, TIME_IMMEDIATE);
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
int rfm69_wait_for_bit_high (*SPID SPID, uint8_t reg_addr, uint8_t mask) {
	int niter=50000;
	while ( (rfm69_register_read(SPID, reg_addr) & mask) == 0) {
		if (--niter == 0) {
			return E_TIMEOUT;
		}
	}
	return E_OK;
}

/** 
 * Test for presence of RFM69
 */
int rfm69_test (*SPID SPID) {
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
void rfm69_config(*SPID SPID) {
	int i;
	for (i = 0; RFM69_CONFIG[i][0] != 255; i++) {
	    rfm69_register_write(SPID, RFM69_CONFIG[i][0], RFM69_CONFIG[i][1]);
	}
}

/**
 * Set RFM69 operating mode. Use macro values RFM69_OPMODE_Mode_xxxx as arg.
 */
int rfm69_mode (*SPID SPID, uint8_t mode) {
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
void rfm69_frame_tx(*SPID SPID, uint8_t *buf, int len) {

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

	rfm69_wait_for_bit_high(SPID, RFM69_IRQFLAGS2, RFM69_IRQFLAGS2_PacketSent);
}

uint8_t rfm69_register_read (*SPID SPID, uint8_t reg_addr) {
	spiSelect(SPID);
	rfm69_spi_transfer_byte(SPID, reg_addr);
	uint8_t reg_value = rfm69_spi_transfer_byte(SPID, 0xff);
	spiUnselect(SPID);
	return reg_value;
}

void rfm69_register_write (*SPID SPID, uint8_t reg_addr, uint8_t reg_value) {
	spiSelect(SPID);
	rfm69_spi_transfer_byte (SPID, reg_addr | 0x80); // Set bit 7 to indicate write op
	rfm69_spi_transfer_byte (SPID, reg_value);
	spiUnselect(SPID);
}

uint8_t rfm69_spi_transfer_byte(*SPID SPID, uint8_t out) {
	//the spi_transfer_byte function in this library is an SPI exchange: out is sent and MISO is sampled synchronously, so think can be replaced with the CHiBiOS spiExchange method
	uint8_t val; 	
	spiExchange(SPID, 1, (void*) &out, (void*) &val);
	
	return val;
}

/*----------------------------Thread-------------------------------------------------*/

msg_t rfm69_thread(void *arg) {
	
	msg_t status, msgp;
	uint8_t *msg;
	
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
	rfm69_config(SPID);
	
	rfm69_mem_init();
	
	if(conf.location == TOP)
		rfm69_log_c(0x00, "TOP");
	else if(conf.location == BOTTOM)
		rfm69_log_c(0x00, "BOTTOM");

	while(TRUE) {
		status = chMBFetch(&rfm69_mb, &msgp, TIME_INFINITE);
		if(status != RDY_OK || msgp == 0) {
			continue;
		}
		
		/**
		 * cast the msgp pointer to be uint8_t so data can be sent using tx function 
		 * on ground station end cast the message back to type char
		**/
		
		msg = (uint8_t*) msgp;  
		rfm69_frame_tx(SPID, msg, 16);
		chPoolFree(&rfm69_mp, (void*)msg);
		rfm69_mode(SPID, RFM69_OPMODE_Mode_STDBY);
	}
	return (msg_t)NULL;
}
	



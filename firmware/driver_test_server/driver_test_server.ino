#include "err.h"
#include "rfm69_rdl.h"
#include "rfm69_config.h"
#include <stdint.h>
#include "SPI.h"

#define SS 10
#define STAGE 1 //1 for bottom stage, 2 for top stage

uint8_t expected_packet_length = 16;
uint8_t maxPktLen = 66;
uint8_t bfr[18];
uint8_t local[67];

uint8_t rfm69_spi_transfer_byte(uint8_t out) {
  uint8_t val = (uint8_t) SPI.transfer(out);

  return val;
}

uint8_t rfm69_register_read (uint8_t reg_addr) {
  digitalWrite(SS, LOW);
  rfm69_spi_transfer_byte(reg_addr);
  uint8_t reg_value = rfm69_spi_transfer_byte(0xff);
  digitalWrite(SS, HIGH);

  return reg_value;
}

void rfm69_register_write (uint8_t reg_addr, uint8_t reg_value) {
  digitalWrite(SS, LOW);
  rfm69_spi_transfer_byte ( reg_addr | 0x80); // Set bit 7 to indicate write op
  rfm69_spi_transfer_byte ( reg_value);
  digitalWrite(SS, HIGH);
}

int rfm69_wait_for_bit_high (uint8_t reg_addr, uint8_t mask) {
  int niter = 50000;
  while ( (rfm69_register_read(reg_addr) & mask) == 0) {
    if (--niter == 0) {
      return E_TIMEOUT;
    }
  }
  return E_OK;
}

/**
 * Test for presence of RFM69
 */
int rfm69_test () {
  // Backup AES key register 1
  int aeskey1 = rfm69_register_read(0x3E);

  rfm69_register_write(0x3E, 0x55);
  if (rfm69_register_read(0x3E) != 0x55) {
    Serial.print(rfm69_register_read(0x3E));
    Serial.print("\n");
    return -1;
  }
  rfm69_register_write(0x3E, 0xAA);
  if (rfm69_register_read(0x3E) != 0xAA) {
    Serial.print(rfm69_register_read(0x3E));
    Serial.print("\n");
    return -1;
  }
  // Restore value
  rfm69_register_write(0x3E, aeskey1);
  return 0;
}
/**
 * Configure RFM69 radio module for use. Assumes SPI interface is already configured.
 */
void rfm69_config() {
  int i;
  for (i = 0; RFM69_CONFIG[i][0] != 255; i++) {
    rfm69_register_write(RFM69_CONFIG[i][0], RFM69_CONFIG[i][1]);
  }

  //433MHz for bottom stage, 434MHz for top stage
  if(STAGE == 1) {
    rfm69_register_write(SPID, RFM69_FRFMID, 0x40);
  } else {
    rfm69_register_write(SPID, RFM69_FRFMID, 0x80);
  }
}

/**
 * Set RFM69 operating mode. Use macro values RFM69_OPMODE_Mode_xxxx as arg.
 */
int rfm69_mode (uint8_t mode) {
  uint8_t regVal = rfm69_register_read(RFM69_OPMODE);
  regVal &= ~RFM69_OPMODE_Mode_MASK;
  regVal |= RFM69_OPMODE_Mode_VALUE(mode);
  rfm69_register_write( RFM69_OPMODE, regVal);

  // Wait until mode change is complete
  // IRQFLAGS1[7] ModeReady: Set to 0 when mode change, 1 when mode change complete
  return rfm69_wait_for_bit_high( RFM69_IRQFLAGS1, RFM69_IRQFLAGS1_ModeReady);
}

/**
 * Get RSSI
 */
uint8_t rfm69_rssi () {

  rfm69_register_write(RFM69_RSSICONFIG, RFM69_RSSICONFIG_RssiStart);

  // Wait for RSSI ready
  //while ((rfm69_register_read(RFM69_RSSICONFIG) & RFM69_RSSICONFIG_RssiDone_MASK) == 0x00);
  rfm69_wait_for_bit_high(RFM69_RSSICONFIG, RFM69_RSSICONFIG_RssiDone);

  return rfm69_register_read(RFM69_RSSIVALUE);
}

/**
 * Check if packet has been received and is ready to read from FIFO.
 * @return zero if no packet available, non-zero if packet available.
 */
uint8_t rfm69_payload_ready() {
  uint8_t reg  = rfm69_register_read(RFM69_IRQFLAGS2) & RFM69_IRQFLAGS2_PayloadReady_MASK;
  return reg >> 2;
}


uint8_t rfm69_frame_rx(uint8_t *buf) {
  //copy into buffer if the message is of the expected length of 16 (or multiples of 16)

  int i;
  uint8_t frame_length;

  digitalWrite(SS, LOW);
  rfm69_spi_transfer_byte(RFM69_FIFO);

  // Read frame length;
  frame_length = rfm69_spi_transfer_byte(0);

  //Serial.print(frame_length);
  for (i = 0; i < expected_packet_length; i++) {
    buf[i] = rfm69_spi_transfer_byte(0);
  }

  buf[16] = 0;

  digitalWrite(SS, HIGH);

  return (frame_length);
}


/**
 * Transmit a frame stored in buf
 */
void rfm69_frame_tx(uint8_t *buf, int len) {

  // Turn off receiver before writing to FIFO
  rfm69_mode(RFM69_OPMODE_Mode_STDBY);

  Serial.print("radio in stdby \n");

  // Write frame to FIFO
  digitalWrite(SS, LOW);
  rfm69_spi_transfer_byte(RFM69_FIFO | 0x80);

  // packet length
  rfm69_spi_transfer_byte(len);

  int i;
  for (i = 0; i < len; i++) {
    rfm69_spi_transfer_byte(buf[i]);
  }

  Serial.print("wrote data to FIFO \n");
  digitalWrite(SS, LOW);

  // Power up TX
  rfm69_mode(RFM69_OPMODE_Mode_TX);

  //Serial.print("Radio in Tx mode \n");

  int wait = rfm69_wait_for_bit_high(RFM69_IRQFLAGS2, RFM69_IRQFLAGS2_PacketSent);

  if (wait == E_TIMEOUT) {
    Serial.print("wait for send timeout");
  }
}


void setup() {
  SPI.begin();
  SPI.setDataMode(SPI_MODE0);
  SPI.setClockDivider(2);
  Serial.begin(115200);

  rfm69_config();

  /*
  int testTx = rfm69_mode(RFM69_OPMODE_Mode_TX);
    if(testTx == E_TIMEOUT) {
      Serial.print("Problem with mode setup \n");
    } else {
       Serial.print("Radio setup in Tx mode \n");
    }
  */

  if (rfm69_test() == 0) {
    Serial.print("Setup OK \n");
  } else {
    Serial.print("Setup failed");
  }



}

void recvFloat() {
  float a, b;

  memcpy((void*)&a, bfr + 8, 4);
  memcpy((void*)&b, bfr + 12, 4);

  char flt_a[5];
  char flt_b[5];

  dtostrf(a, 4, 2, flt_a);
  dtostrf(b, 4, 2, flt_b);

  Serial.print("Float one:");
  Serial.print(flt_a);
  Serial.print("\n");
  Serial.print("Float two:");
  Serial.print(flt_b);
  Serial.print("\n");

  delay(1000);
}

void loop() {

  uint8_t recv_ready = rfm69_payload_ready();
  //Serial.print(recv_ready);
  //Serial.print("\n");
  if ( recv_ready == 1 ) {

    if (rfm69_frame_rx(bfr) == 16) {
      for (int i = 0; i < 16; i++) {
        if (bfr[i] < 16) {
          Serial.print(0, HEX);
        }
        Serial.print(bfr[i], HEX);

      }
      Serial.print("\n");
    }
  }
}


import datetime
import sys
import time
import iso8601
import serial

ONE_SEC = datetime.timedelta(seconds=1)

def format_gprmc(dt):
	str= "GPRMC,{}.000,A,5321.6802,N,00630.3372,W,0.02,31.66,{},,,A".format(
		dt.strftime('%H%M%S'),
		dt.strftime('%d%m%y')
	)

	checksum = 0
	for c in str:
		checksum ^= ord(c)
	return ("$%s*%02X\n" % (str, checksum)).encode('ascii')

with serial.Serial('/dev/ttyUSB', 9600) as ser:
	ser.rts = True

	if len(sys.argv) >= 2:
		start_at = iso8601.parse_date(sys.argv[1])
	else:
		start_at = datetime.datetime.utcnow()

	while True:
		now = datetime.datetime.utcnow()
		us = now.microsecond
		time.sleep((1000000 - us) / 1000000)
		ser.rts = False
		time.sleep(0.1)
		ser.rts = True

		start_at += ONE_SEC
		ser.write(format_gprmc(start_at))


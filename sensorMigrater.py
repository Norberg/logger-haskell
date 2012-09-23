#!/usr/bin/python
import time, datetime, os
import sqlite3, pymongo

old_readings = dict()

def add_reading(date, value, name):
	if not old_readings.has_key(date):
		old_readings[date] = {"indoor":0, "outdoor":0}
	
	old_readings[date][name] = value

def fromISO(date):
	return datetime.datetime.strptime(date, "%Y-%m-%dT%H:%M")

def main():
	conn = sqlite3.connect("sensors.db")
	c = conn.cursor()
	mongoConn = pymongo.Connection()
	readings = mongoConn.sensors.temperature
	for row in c.execute('SELECT * FROM sensors;'):
		#print row
		add_reading(row[0] +"T"+ row[1], row[2], row[4])
	
	for d,r in old_readings.items():
		try:
			date = fromISO(d)
			ind = float(r["indoor"])
			out = float(r["outdoor"])
			doc = {"datetime": date, "readings" : {"indoor":ind, "outdoor":out}}
			readings.insert(doc)
		except:
			print "could not insert row:", r
	c.close()
			

if __name__ == "__main__":
	main()

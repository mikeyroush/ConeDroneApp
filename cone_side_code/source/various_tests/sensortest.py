import sensor

dist_arr = [False,0]
schedule.every(00.004).seconds.do(sensor.checkSensor,distance_arr)

while true:
    schedule.run_pending()
    [indicate,dist] = dist_arr
    
    print(str(bus.read_byte_data(0x10, 0x00)), str(bus.read_byte_data(0x10, 0x01)), str(bus.read_byte_data(0x10, 0x02)), str(bus.read_byte_data(0x10, 0x03)))
    print(indicate,dist)
    
def flyover_success(distance):
	if(distance > 4):
		flyover = True
	else:
		flyover = False
	return flyover


def convert_sensor_data(data):
	dist = data/100
	return dist
import unittest
from sensor import flyover_success
from sensor import convert_sensor_data
from indicator import indicator_led
from indicator import indicator_flag
from messages import parseMessage
from messages import craftMessage

class Tests(unittest.TestCase):
    def test_distance_more_than_four(self):
        result = flyover_success(5)
        self.assertTrue(result) 
    def test_distance_more_than_four_float(self):
        result = flyover_success(4.01)
        self.assertTrue(result) 
    def test_distance_less_than_four(self):
        result = flyover_success(3)
        self.assertFalse(result)
    def test_distance_less_than_four_float(self):
        result = flyover_success(3.99)
        self.assertFalse(result)
    def test_distance_equal_to_four(self):
        result = flyover_success(4)
        self.assertFalse(result)
    def test_distance_equal_to_four_float(self):
        result = flyover_success(4.00)
        self.assertFalse(result)

    def test_sensor_data_converter100(self):
        result = convert_sensor_data(100)
        self.assertEqual(result,1)
    def test_sensor_data_converter1(self):
        result = convert_sensor_data(1)
        self.assertEqual(result,0.01)
    def test_sensor_data_converter390(self):
        result = convert_sensor_data(398.428)
        self.assertEqual(result,3.98428)



    def test_led_true_flyover(self):
        result = indicator_led(flyover_success(5))
        self.assertEqual(result,1)
    def test_led_false_flyover(self):
        result = indicator_led(flyover_success(3.998))
        self.assertEqual(result,0)
    def test_flag_true_flyover(self):
        result = indicator_flag(flyover_success(5))
        self.assertEqual(result,1)
    def test_flag_false_flyover(self):
        result = indicator_flag(flyover_success(3.998))
        self.assertEqual(result,0)


#message parser

    def test_msg_parser1(self):
        result = parseMessage(b'\x00\x00\x01\x81\x00\x0c\xa8\x2b')
        self.assertEqual(result,("reset", "dronecone385", "829483"))
    def test_msg_parser2(self):
        result = parseMessage(b'\x01\x00\x13\x38\x00\x35\x4c\x9d')
        self.assertEqual(result,("indicate", "dronecone4920", "3493021"))
    def test_msg_parser3(self):
        result = parseMessage(b'\x02\xff\xff\xff\x00\x00\x07\xf7')
        self.assertEqual(result,("new node", "dronecone16777215", "2039"))
    def test_msg_parser4(self):
        result = parseMessage(b'\x03\x00\x00\x04\xff\xff\xff\xff')
        self.assertEqual(result,("node lost", "dronecone4", "4294967295"))
    def test_msg_parser5(self):
        result = parseMessage(b'\x04\x00\x28\x35\x00\x00\x00\x12')
        self.assertEqual(result,("reset all", "dronecone10293", "18"))


#message crafter


    def test_msg_crafter1(self):
        result = craftMessage("reset", "dronecone123456")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x1e240)
    def test_msg_crafter2(self):
        result = craftMessage("indicate", "dronecone48394")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x0100bd0a)    
    def test_msg_crafter3(self):
        result = craftMessage("new node", "dronecone3")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x02000003)
    def test_msg_crafter4(self):
        result = craftMessage("node lost", "dronecone2304023")
        self.assertEqual(int.from_bytes(result[0:4], "big"), 0x03232817)
    def test_msg_crafter5(self):
        result = craftMessage("reset all", "dronecone9382934")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x048f2c16)
    
    




if __name__ == '__main__':
    unittest.main()
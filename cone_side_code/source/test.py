import unittest
from sensor import interpretDistance
from indicator import indicator_led
from indicator import indicator_flag
from messages import parseMessage
from messages import craftMessage

class Tests(unittest.TestCase):
    def test_distance_more_than_four(self):
        result = interpretDistance(500)
        self.assertTrue(result) 
    def test_distance_more_than_four_float(self):
        result = interpretDistance(400.01)
        self.assertTrue(result) 


    def test_led_true_flyover(self):
        result = indicator_led(True)
        self.assertEqual(result,1)
    def test_led_false_flyover(self):
        result = indicator_led(False)
        self.assertEqual(result,0)
    def test_flag_true_flyover(self):
        result = indicator_flag(True)
        self.assertEqual(result,1)
    def test_flag_false_flyover(self):
        result = indicator_flag(False)
        self.assertEqual(result,0)


#message parser

    def test_msg_parser1(self):
        result = parseMessage(b'\x00\x00\x01\x81\x00\x0c\xa8\x2b')
        self.assertEqual(result,("reset", "dronecone385", "829483", 'dronecone0'))
    def test_msg_parser2(self):
        result = parseMessage(b'\x01\x00\x0f\xb4\x00\x35\x4c\x9d')
        self.assertEqual(result,("indicate", "dronecone4020", "3493021", 'dronecone0'))
    def test_msg_parser3(self):
        result = parseMessage(b'\x02\x25\x06\x8d\x00\x00\x07\xf7')
        self.assertEqual(result,("new node", "dronecone1677", "2039", "dronecone592"))
    def test_msg_parser4(self):
        result = parseMessage(b'\x03\x72\x80\x04\xff\xff\xff\xff')
        self.assertEqual(result,("node lost", "dronecone4", "4294967295", "dronecone1832"))
    def test_msg_parser5(self):
        result = parseMessage(b'\x04\x00\x04\x05\x00\x00\x00\x12')
        self.assertEqual(result,("reset all", "dronecone1029", "18", 'dronecone0'))
    def test_msg_parser6(self):
        result = parseMessage(b'\x05\x00\x01\x7e\x00\x00\x0f\x3e')
        self.assertEqual(result,("ack", "dronecone382", "3902", 'dronecone0'))


#message crafter


    def test_msg_crafter1(self):
        result = craftMessage("reset", "dronecone1234")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x000004d2)
    def test_msg_crafter2(self):
        result = craftMessage("indicate", "dronecone483")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x010001e3)    
    def test_msg_crafter3(self):
        result = craftMessage("new node", "dronecone3", name2="dronecone3002")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x02bba003)
    def test_msg_crafter4(self):
        result = craftMessage("node lost", "dronecone2304", name2="dronecone2991")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x03baf900)
    def test_msg_crafter5(self):
        result = craftMessage("reset all", "dronecone938")
        self.assertEqual(int.from_bytes(result[0:4], "big"),0x040003aa)
    def test_msg_crafter6(self):
        result = craftMessage("ack", "dronecone392", num="48923035")
        self.assertEqual(int.from_bytes(result, "big"),0x0500018802ea819b)
    
    






if __name__ == '__main__':
    unittest.main()
from confluent_kafka import Producer, Consumer, KafkaException
import socket, os, logging


class KafkaProducer:    
    def __init__(self, bootstrap_servers: str, 
                 client_id: str = socket.gethostname(),
                 use_sasl=False,
                 sasl_mechanism="PLAIN", 
                 sasl_username="", 
                 sasl_password="", 
                 producer_config: dict ={}  # can be used to override previous configs
                 ):
        self.bootstrap_servers = bootstrap_servers
        if use_sasl:
            self.producer_config = {
                'bootstrap.servers': self.bootstrap_servers,
                'security.protocol': 'SASL_SSL',
                'sasl.mechanism': sasl_mechanism,
                'sasl.username': sasl_username,
                'sasl.password': sasl_password,
                'client.id': client_id,
                ** producer_config
            }
        else:
            self.producer_config = {
                'bootstrap.servers': self.bootstrap_servers,
                'client.id': client_id,
                ** producer_config
            }
        self.producer = Producer(self.producer_config)
        

    @staticmethod
    def from_env_vars(client_id: str = socket.gethostname(),
                      producer_config: dict ={}  # can be used to override previous configs
                      ):
        '''
        Creates a KafkaProducer from environment variables.
        Uses the following environment variables:
        - KAFKA_BROKER: comma-separated list of kafka brokers
        - KAFKA_USE_SASL: whether to use SASL authentication (default: False)
        - KAFKA_PRODUCER_USERNAME: SASL username (default: "")
        - KAFKA_PRODUCER_PASSWORD: SASL password (default: "")
        You can further override these by providing arguments in the producer_config dict.
        '''
        kafka_broker = os.getenv('KAFKA_BROKER')
        use_sasl = os.getenv('KAFKA_USE_SASL')
        producer_username = os.getenv('KAFKA_PRODUCER_USERNAME')
        producer_password = os.getenv('KAFKA_PRODUCER_PASSWORD')

        if type(use_sasl) == str and use_sasl.lower() == 'true':
            return KafkaProducer(kafka_broker, 
                                 client_id, 
                                 use_sasl=True, 
                                 sasl_username=producer_username, 
                                 sasl_password=producer_password,
                                 producer_config=producer_config)
        else:
            return KafkaProducer(kafka_broker, client_id,  producer_config=producer_config)


    def send_message(self, topic: str, 
                     value: str,
                     key: str = None, 
                     callback_func = None):
        '''Sends a message to a topic (via `produce()`) and flushes.'''
        
        self.producer.produce(topic, value=value, key=key, callback=callback_func)
        self.producer.flush()
            

    def _send_message_async(self, topic: str, 
                     value: str,
                     key: str = None, 
                     callback_func = None):
        self.producer.produce(topic, value=value, key=key, callback=callback_func)
    
    def poll_for_callback(self, timeout=1.0):
        '''Polls for callback. To be used with `send_message_async`'''
        self.producer.poll(timeout=timeout)


class KafkaConsumer:
    def __init__(self, bootstrap_servers: str, 
                 group_id: str,
                 auto_offset_reset: str,
                 use_sasl=False,
                 sasl_mechanism="PLAIN", 
                 sasl_username="", 
                 sasl_password="", 
                 consumer_config: dict ={}  # can be used to override previous configs
                 ):
        self.bootstrap_servers = bootstrap_servers
        if use_sasl:
            self.consumer_config = {
                'bootstrap.servers': self.bootstrap_servers,
                'group.id': group_id,
                'auto.offset.reset': auto_offset_reset,
                'security.protocol': 'SASL_SSL',
                'sasl.mechanism': sasl_mechanism,
                'sasl.username': sasl_username,
                'sasl.password': sasl_password,
                ** consumer_config
            }
        else:
            self.consumer_config = {
                'bootstrap.servers': self.bootstrap_servers,
                'group.id': group_id,
                'auto.offset.reset': auto_offset_reset,
                ** consumer_config
            }
        # print("consumer config", self.consumer_config)
        self.consumer = Consumer(self.consumer_config)
        self.subscribed=False
        self.subscribed_topics = []

    @staticmethod
    def from_env_vars(group_id: str, auto_offset_reset: str):
        '''
        Creates a KafkaConsumer from environment variables.
        Uses the following environment variables:
        - KAFKA_BROKER: comma-separated list of kafka brokers
        - KAFKA_USE_SASL: whether to use SASL authentication (default: False)
        - KAFKA_CONSUMER_USERNAME: SASL username (default: "")
        - KAFKA_CONSUMER_PASSWORD: SASL password (default: "")
        You can further override these by providing arguments in the consumer_config dict.
        '''
        kafka_broker = os.getenv('KAFKA_BROKER')
        use_sasl = os.getenv('KAFKA_USE_SASL')
        consumer_username = os.getenv('KAFKA_CONSUMER_USERNAME')
        consumer_password = os.getenv('KAFKA_CONSUMER_PASSWORD')

        print("Consumer from env vars")
        # print(kafka_broker, use_sasl, consumer_username, consumer_password)

        if type(use_sasl) == str and use_sasl.lower() == 'true':
            return KafkaConsumer(kafka_broker, 
                                 group_id, 
                                 auto_offset_reset,
                                 use_sasl=True, 
                                 sasl_username=consumer_username, 
                                 sasl_password=consumer_password)
        else:
            return KafkaConsumer(kafka_broker, 
                                 group_id, 
                                 auto_offset_reset)

    def subscribe(self, topics: list):
        self.consumer.subscribe(topics)
        self.subscribed=True
        self.subscribed_topics = topics
        

    def receive_message(self, topic, timeout=60) -> str:
        if not self.subscribed:
            self.subscribe([topic])
        while True:
            msg = self.consumer.poll(timeout)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            return(msg.value().decode('utf-8'))

#https://neo4j.com/docs/developer-manual/current/drivers/client-applications/
from neo4j.v1 import GraphDatabase

## Edit this-
username,password = "neo4j","neo4j"

class HelloWorldExample(object):

    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self._driver.close()

    def print_greeting(self, message):
        with self._driver.session() as session:
            greeting = session.write_transaction(self._create_and_return_greeting, message)
            print(greeting)

    @staticmethod
    def _create_and_return_greeting(tx, message):
        result = tx.run("CREATE (a:Greeting) "
                        "SET a.message = $message "
                        "RETURN a.message + ', from node ' + id(a)", message=message)
        return result.single()[0]

h = HelloWorldExample("bolt://127.0.0.1:7687",username,password)
h.print_greeting("Hello World")
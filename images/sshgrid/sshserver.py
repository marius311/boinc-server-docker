import asyncio, sys, sqlite3

import asyncssh
from asyncssh import SSHServer, SSHListener, import_private_key
from contextlib import closing

def handle_session(stdin, stdout, stderr):
    stdout.write('Welcome to my SSH server, %s!\n' %
                 stdout.channel.get_extra_info('username'))
    # stdout.channel.exit(0)

class MySSHServer(SSHServer):

    def connection_made(self, conn):
        print('SSH connection received from %s.' %
                  conn.get_extra_info('peername')[0])
        self._conn = conn

    def connection_lost(self, exc):
        if exc:
            print('SSH connection error: ' + str(exc), file=sys.stderr)
        else:
            print('SSH connection closed.')
            
    def server_requested(self, listen_host, listen_port):
        # schedule something here which 
        return True

    def public_key_auth_supported(self):
        return True
        
    def validate_public_key(self, username, key):
        with sqlite3.connect("keys.db") as db:
            with closing(db.cursor()) as c:
                client_key = c.execute("SELECT client_priv FROM keys WHERE client_username='{0}'".format(username)).fetchone()
                if client_key:
                    return import_private_key(client_key[0]).convert_to_public() == key
                else:
                    # print("not found {0}".format(username))
                    return False
        
        


async def start_server():
    await asyncssh.create_server(MySSHServer, '', 8022,
                                 server_host_keys=['ssh_host_key'],
                                 session_factory=handle_session)

loop = asyncio.get_event_loop()

try:
    loop.run_until_complete(start_server())
except (OSError, asyncssh.Error) as exc:
    sys.exit('Error starting server: ' + str(exc))

loop.run_forever()

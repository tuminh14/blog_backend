#### Change permission of scripts for postgres user docker

The folder *.scripts/* will be mounted to */docker-entrypoint-initdb.d/* inside the postgres
container with the same permission as it have from the host, it is necessary to change the permission
so that it can be executed by the postgres user:

```bash
    sudo chown :70 -R ./scripts && \
    chmod 750 -R ./scripts/ 
```
   
    
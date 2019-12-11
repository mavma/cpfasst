# cpfasst

Build docker image
```
docker build -t ubuntu-mpich docker
```

Run interactive shell on docker
```
docker run --rm -it -v `pwd`:/project ubuntu-mpich
```

Build project
```
make
```

Run example
```
./cmain
```

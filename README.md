# cpfasst

### Run the program

Clone and initialize submodules
```
git clone https://github.com/mavma/cpfasst.git
git submodule update --init --recursive
```

Build project
```
make
```

Run example
```
./cmain
```

### Run using Docker

Build Docker images
```
docker build -t ubuntu-mpich docker/ubuntu-mpich
docker build -t alpine-mpich docker/alpine-mpich
```

Run interactive shell on Docker container with the desired image
```
docker run --rm -it -v `pwd`:/project image-name
```


### Developer setup

Use commit hooks
```
git config core.hooksPath .githooks
```
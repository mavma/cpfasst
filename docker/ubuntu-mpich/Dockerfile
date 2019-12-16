FROM ubuntu:19.04

ARG PACKAGES="build-essential mpich valgrind"
RUN apt-get update && apt-get upgrade -y && apt-get install -y ${PACKAGES}

#### ADD DEFAULT USER ####
ARG USER=mpi
RUN useradd -ms /bin/bash ${USER}
ENV USER_HOME /home/${USER}

#### CREATE WORKING DIRECTORY FOR USER ####
ARG WORKDIR=/project
ENV WORKDIR ${WORKDIR}
RUN mkdir ${WORKDIR}
RUN chown -R ${USER}:${USER} ${WORKDIR}

WORKDIR ${WORKDIR}
USER ${USER}

CMD ["/bin/bash"]

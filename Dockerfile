FROM fbarilla/powerai-r5

# increment to force rebuild
ENV BASE_POWERAI5_BUILD 1

# Nimbix bits and Nimbix desktop
RUN curl -H 'Cache-Control: no-cache' \
    https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
    | bash -s -- --setup-nimbix-desktop

ADD https://raw.githubusercontent.com/nimbix/notebook-common/master/install-centos.sh /tmp/install-centos.sh
RUN bash /tmp/install-centos.sh && rm -f /tmp/install-centos.sh
# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# for standalone use
EXPOSE 5901
EXPOSE 443
EXPOSE 8888

# Additional packages
RUN yum -y install bzip2 && yum clean all

# workaround for older systems
RUN mkdir -p /usr/lib/powerpc64le-linux-gnu

RUN yum -y install wget python-devel
RUN yum install -y openssh-server.ppc64le
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN ssh-keygen -A
RUN systemctl disable sshd
RUN yum install -y openblas
RUN yum install -y atlas atlas-dev

# RUN useradd demo
# USER demo
# WORKDIR /home/demo
# RUN wget https://repo.continuum.io/archive/Anaconda2-5.0.0-Linux-ppc64le.sh
# RUN bash Anaconda2-5.0.0-Linux-ppc64le.sh -b
# RUN echo "export PATH=/home/demo/anaconda2/bin:$PATH" >> /home/demo/.bashrc
# RUN source ~/.bashrc

# Anaconda - install using batch
WORKDIR /tmp
RUN curl -O https://repo.continuum.io/archive/Anaconda2-5.0.0-Linux-ppc64le.sh && bash ./Anaconda*.sh -b -p /opt/anaconda2 && rm -f Anaconda*.sh
RUN echo 'export PATH=/opt/anaconda2/bin:$PATH' >>/etc/profile.d/zz_conda.sh
ENV PATH /opt/anaconda2/bin:$PATH

# USER root
# COPY install-centos.sh /tmp/install-centos.sh
# RUN /tmp/install-centos.sh
# RUN echo "nimbix  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# RUN echo "demo  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# RUN sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

COPY NAE/help.html /etc/NAE/help.html
COPY NAE/screenshot.png /etc/NAE/screenshot.png
COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# RUN mkdir -p /demo
COPY samples /usr/local/samples/demo
# RUN chown -R demo:demo /usr/local/samples
RUN chmod -R 777 /usr/local/samples
COPY scripts/sample_notebook.sh /usr/local/scripts/sample_notebook.sh

# USER demo
# RUN PATH=/home/demo/anaconda2/bin:$PATH /opt/DL/tensorflow/bin/install_dependencies
# RUN PATH=/home/demo/anaconda2/bin:$PATH /opt/DL/tensorboard/bin/install_dependencies
# RUN PATH=/home/demo/anaconda2/bin:$PATH /opt/DL/caffe-ibm/bin/install_dependencies
# RUN PATH=/home/demo/anaconda2/bin:$PATH /opt/DL/caffe-bvlc/bin/install_dependencies
# RUN echo "export PATH=/home/demo/anaconda2/bin:/usr/local/lib:$PATH" >> /home/demo/.bashrc
# RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/cuda/targets/ppc64le-linux/lib/" >> /home/demo/.bashrc

# Install framework dependencies
RUN for i in `find /opt/DL -name install_dependencies`; do echo "Running $i..."; echo "y"|$i; done

#add Jupyter
USER root
RUN pip install --upgrade pip
RUN pip install notebook 
RUN pip install jupyter
RUN pip install ijson
RUN pip install pandas==0.20.3

RUN pip install pandas_datareader==0.5.0
RUN pip install httplib2
RUN pip install cython
RUN pip install pyspark
RUN pip install ibmseti
RUN pip install python-resize-image

# WORKDIR /root
# RUN wget https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz
# RUN tar -xvf spark-2.2.0-bin-hadoop2.7.tgz

RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/local/cuda/targets/ppc64le-linux/lib/" >> /etc/profile


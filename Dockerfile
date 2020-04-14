FROM daocloud.io/library/centos:7.6.1810
MAINTAINER wangmeng <wmlucas.cn@gmail.com>

#======安装 python3============#

RUN set -ex \
    # 预安装所需组件
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
    && wget https://npm.taobao.org/mirrors/python/3.5.0/Python-3.5.0.tgz \
    && tar -zxvf Python-3.5.0.tgz \
    && cd Python-3.5.0 \
    && ./configure prefix=/usr/local/python3 \
    && make \
    && make install \
    && make clean \
    && rm -rf /Python-3.5.0* \
    && yum install -y epel-release \
    && yum install -y python-pip
# 设置默认为python3
RUN set -ex \
    # 备份旧版本python
    && mv /usr/bin/python /usr/bin/python27 \
    && mv /usr/bin/pip /usr/bin/pip-python2.7 \
    # 配置默认为python3
    && ln -s /usr/local/python3/bin/python3.5 /usr/bin/python \
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
# 修复因修改python版本导致yum失效问题
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/libexec/urlgrabber-ext-down \
    && yum install -y deltarpm
# 基础环境配置
RUN set -ex \
    # 修改系统时区为东八区
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum install -y vim \
    # 安装定时任务组件
    && yum -y install cronie
# 支持中文
RUN yum install kde-l10n-Chinese -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
# 更新pip版本
RUN pip install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/
ENV LC_ALL zh_CN.UTF-8

#======安装nginx============#


RUN yum install wget -y && \
    wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/centos.repo && \
    yum install --nogpgcheck gcc make pcre-devel zlib-devel wget -y  &&  \
    wget http://nginx.org/download/nginx-1.16.0.tar.gz && \
    tar xf nginx-1.16.0.tar.gz && \
    rm -rf nginx-1.16.0.tar.gz && \
    cd nginx-1.16.0 && \
    ./configure --prefix=/usr/local/nginx --with-pcre && echo "999999" && \
    make && make install && \
    echo "daemon off;" >> /usr/local/nginx/conf/nginx.conf && \
    yum clean all


#===python 依赖#


RUN pip install requests -i https://mirrors.aliyun.com/pypi/simple/


#打开80端口
EXPOSE 80
#启动容器
CMD ["/usr/local/nginx/sbin/nginx"]





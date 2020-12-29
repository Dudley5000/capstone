FROM nwareing/perl-python
RUN pip install --upgrade pip
RUN pip install pandas
RUN pip install 'Cython==0.28.5'
RUN pip install sklearn
RUN cpanm Mojolicious
ENV MOJO_LISTEN http://*:8080
ADD . /app
EXPOSE 8080
WORKDIR /app
RUN chmod +x website.pl
CMD ["morbo", "./website.pl"]
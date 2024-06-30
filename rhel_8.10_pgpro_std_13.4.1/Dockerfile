FROM registry.access.redhat.com/ubi8/ubi:8.10

#Update from repository
#RUN dnf update -y

#Add locales
RUN dnf install -y glibc-langpack-uk glibc-langpack-ru
#Set locales
ENV LANG=uk_UA.UTF-8

#Set POSTGRES variables
ENV PGDATA=/_data/pg_data

#Explicitly set user/group IDs and data dir
RUN groupadd -r postgres --gid=9999 ; \
    useradd -r -g postgres --uid=9999 postgres ; \
    mkdir -p $PGDATA ; \
    chown -R postgres:postgres $PGDATA ; \
    chmod 700 $PGDATA

#Disable the built-in PostgreSQL module
RUN dnf -qy module disable postgresql
#Install the repository PosrgesPRO-STD-13 (archive)
RUN dnf install -y https://repo.postgrespro.ru/std/archive/std-13.4.1/keys/postgrespro-std-13.rhel.yum-13-0.3.noarch.rpm
RUN sed -ri "s|pgpro-archive/pgpro-13.4.1|std/archive/std-13.4.1|g" /etc/yum.repos.d/postgrespro-std-13.repo
RUN dnf install -y postgrespro-std-13-server postgrespro-std-13-contrib
RUN dnf clean all

#Change settings
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /opt/pgpro/std-13/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(logging_collector)\s*=\s*\S+.*!\1 = on!" /opt/pgpro/std-13/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(log_directory)\s*=\s*\S+.*!\1 = 'log'!" /opt/pgpro/std-13/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(lc_messages)\s*=\s*\S+.*!\1 = 'C.UTF-8'!" /opt/pgpro/std-13/share/postgresql.conf.sample

#Setup for start
ENV PATH $PATH:/opt/pgpro/std-13/bin
COPY container-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/container-entrypoint.sh

#Change user
USER postgres

EXPOSE 5432

ENTRYPOINT ["container-entrypoint.sh"]

CMD ["postgres"]

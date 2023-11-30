#Définit l'image utilisé (ubuntu)
FROM ubuntu:20.04
#utilisera les fichiers .php et .nginx
COPY package*.php ./ package*.nginx ./
#desactive l'invite pendant l'installation
ARG DEBIAN_FRONTEND=nonintrective .
#éxécute les commandes
# met à jour
RUN apt update
#ligne 1 installe nginx, php et supervisor,ligne 2      , ligne 3 supprime le cache des packages pour réduire la taille de l'image 
RUN  apt install -y nginx php-fpm supervisor && \
	rm -rf /var/lib/apt/lists/* && \
	apt clean
#ligne 1 variable indiquant le chemin à prendre pour éxécuter la VAR nginx_vhost, ligne 2 php_conf, ligne 3 nginx_conf, ligne 4 supervisor_conf,
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.4/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf
#
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \ 
	echo "\ndaemon off;" >> ${nginx_conf}
#copie la configuration de supervisor personnalisée dans la variable supervisor_conf
COPY supervisord.conf ${supervisor_conf}
#créer un nouveau dossier pour le fichier sock PHP-FPM et modifie sa racine web et son dossier en utilisateur par defaut www-data
RUN mkdir -p /run/php && \ 
	chown -R www-data:www-data /var/www/html && \ 
	chown -R www-data:www-data /run/php
#modifie le volume de l'image pour pouvoir monter tous les dossiers sur la machine hote. Lie les dossiers au container
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/www/html"]
#lance le script
COPY start.sh /start.sh
CMD ["./start.sh"]
#indique le port utilisé
EXPOSE 80 443
#spécifie les arguments pour lancer des commandes par defaut lors du démarrage d'un conteneur
#CMD [\"/usr/bin/supervisord\""php", "-S 0.0.0.0:80", "./index.php""nginx", "-g", "daemon off;"]

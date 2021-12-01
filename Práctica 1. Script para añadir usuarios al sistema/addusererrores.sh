#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# add_user - Un script para añadir usuario al sistema

error_exit() { #Función para mostrar un mensaje de error y salir del script
	echo "$1" 1>&2
	exit 1
}

user_add() {
	useradd "$1"
	if [ "$?" = 0 ]; then
		echo Usuario creado: "$1"
	fi
}

group_add() {

	usermod -aG "$1" "$username"
	echo Se ha añadido el usuario "$username" a el grupo "$1".
}

password() {

	echo "$username" | passwd --stdin "$username"
	chage -M "$1" -W "$2" -I "$3" "$username"
}

temp() {

	x=$(date +"%s")
	fecha=$(($(echo $(($x / 3600 / 24))) + $1))
	chage -E "$fecha" "$username"
}

usage() { #CAMBIAR
	echo "usage: ./add_user.sh [[[-a user] [[[-g group] [-p maxlife warn inactive | -p ] | [-h]] | [-g user group] | [-p [ user | user maxlife warn inactive ] ]"
}

username=
temporal=false

while [ "$1" != "" ]; do
	case $1 in
	-a | --add)
		shift
		if [ "$1" != "" ]; then
			username=$1
			user_add "$1"
		else
			error_exit "No se ha introducido ningún nombre de usuario"
		fi
		;;

	-g | --group)
		shift
		if [ "$1" != "" ]; then

			if [ "$username" = "" ]; then
				username=$1
				shift
			fi
			group_add "$1"
		fi
		;;

	-p | --password)
		shift
		if [ "$1" != "" ]; then

			if [ "$username" = "" ]; then
				username=$1
				shift
			fi

			if [ "$1" != "" ]; then
				password "$1" "$2" "$3" # maxlife warn inactive
				shift
				shift
			else
				password 90 1 2
			fi
		else
			password 90 1 2
		fi
		;;

	-t | --temporal)
		shift
		temp "$1"
		;;

	\
		-h | --help)
		usage
		exit
		;;
	*) error_exit "Se ha introducido una opción no soportada por el script" ;;
	esac
	shift
done

if ["$1" = ""]; then
	error_exit "Se ha introducido una opción no soportada por el script. Usa el comando ./add_user.sh -h "
fi

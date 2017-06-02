alias dk="docker"

# get container process
alias dkps="docker ps"

# get latest container ID
alias dkpl="docker ps -l -q"

# get process included stop container
alias dkpa="docker ps -a"

# get images
alias dki="docker images"

# get container IP
alias dkip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# run deamonized container, e.g., $dkd base /bin/echo hello
alias dkd="docker run -d -P"

# Run interactive container, e.g., $dki base /bin/bash
alias dkit="docker run -i -t -P"

# execute interactive container, e.g., $dex base /bin/bash
alias dkex="docker exec -i -t"

# stop all containers
dkstop() { docker stop $(docker ps -a -q); }

# remove all containers
dkrm() { docker rm $(docker ps -a -q); }

# stop and remove all containers
alias dkrmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

# remove all images
dkrmi() { docker rmi $(docker images -q); }

# show all alias related docker
dkalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# bash into running container
dkbash() { docker exec -it $(docker ps -aqf "name=$1") bash; }

# remove all container if possible, exited volumes, and dangling images
dkclean(){
  local containers
  containers=( $(docker ps -aq 2>/dev/null) )
  docker rm "${containers[@]}" 2>/dev/null
  local volumes
  volumes=( $(docker ps --filter status=exited -q 2>/dev/null) )
  docker rm -v "${volumes[@]}" 2>/dev/null
  local images
  images=( $(docker images --filter dangling=true -q 2>/dev/null) )
  docker rmi "${images[@]}" 2>/dev/null
}

compctl -K __docker_complete_containers_names dkbash
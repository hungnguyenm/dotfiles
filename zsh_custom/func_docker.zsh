dk-cleanup(){
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
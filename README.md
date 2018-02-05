### Multistage build for Nginx
+ The Dockerfile has non optimized instruction for build nginx from source
+ The multistage docker file has optimized instruction for optimizing the Dockerfile
+ The optimiztion is a good example of how you can plan & include the dependency & achieve a minimalistic docker image whilist being explicit by separting the build stages 
+ Scratch Image (just one layer) is used to reduce footprint, which seems to be the best practice

### Health Check option
Additional Health check option is added. To test from command line execute the following command in the order. Note the additional capability is required to bring down the network interface on the container
+ docker container run -d --name healthcheck_test --cap-add NET_ADMIN -p 8080:80 <image name with tags>

Let's introduce the problem which fails the health check
+ docker exec -it healthcheck_test /bin/bash -c "sleep 10; ip link set lo down; sleep 15; ip link set lo up"

Watch from one window to see the status of healthcheck toggling
+ watch -n 1 "docker container ls"

You can also watch historical record of docker State change events for last 10 mins
+ docker system events --since 10m --filter event=health

The instruction does not change much if you are running 'yum' based linux OS
### Docker command reference
+ http://files.zeroturnaround.com/pdf/zt_docker_cheat_sheet.pdf
+ https://dockerlux.github.io/pdf/cheat-sheet-v2.pdf

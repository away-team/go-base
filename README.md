# go-base
A base service to start new services from

## Getting Started

* Clone to new service folder
* Initialize the new service
* Use your vendoring method of choice.  I recommend [govendor](https://github.com/kardianos/govendor)
* Change the remote to your new service's URL
* Push

```sh
git clone git@github.com:away-team/go-base.git new-service
cd new-service
sh init.sh <serviceName>

# go mod init github.com/<org>/<repo>
# go mod tidy
# go mod vendor
# goimports -w src/main/
# goimports -w src/server/

git remote set-url origin git://new.url.here
git add *
git commit -m "initial clone"
git push -u origin master
```

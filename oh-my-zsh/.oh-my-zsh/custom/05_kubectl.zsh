#!/usr/bin/env zsh

autoload -Uz compinit; compinit
source <(kubectl completion zsh)


command -v kubecolor >/dev/null 2>&1 && alias kubectl="kubecolor" && compdef kubecolor=kubectl

alias k='kubectl'

# kubectl apply
alias kaf='k apply -f'

# kubectl config
alias kccc='k config current-context'
alias kcdc='k config delete-context'
alias kcgc='k config get-contexts'
alias kcn='k config set-context --current --namespace'
alias kcsc='k config set-context'
alias kcuc='k config use-context'
alias kcdelcl='k config delete-cluster'
alias kcdelu='k config delete-user'
alias kcgcl='k config get-clusters'
alias kcgu='k config get-users'
alias kcrc='k config rename-context'
alias kcscr='k config set-credentials'
alias kcscl='k config set-cluster'
alias kcs='k config set'
alias kcu='k config unset'
alias kcv='k config view'


# kubectl copy
alias kcp='k cp'

# kube context
alias kctx='kubectx'

# kubectl delete

alias kdel='k delete'
alias kdeln='kdel -n'
alias kdelf='k delete -f'

alias kdelcr='kdel certificaterequest'
alias kdelcrn='kdelcr -n'
alias kdelcj='kdel cronjob'
alias kdelcjn='kdelcj -n'
alias kdelc='kdel certificate'
alias kdelcn='kdelc -n'
alias kdelcsr='kdel certificatesigningrequest'
alias kdelcsrn='kdelcsr -n'
alias kdelcm='kdel configmap'
alias kdelcmn='kdelcm -n'
alias kdelcrd='kdel customresourcedefinition'
alias kdelcrdn='kdelcrd -n'
alias kdelds='kdel daemonset'
alias kdeldsn='kdelds -n'
alias kdeld='kdel deployment'
alias kdeldn='kdeld -n'
alias kdele='kdel endpoint'
alias kdelen='kdele -n'
alias kdeles='kdel externalsecret'
alias kdelesn='kdeles -n'
alias kdelgr='kdel gitrepository'
alias kdelgrn='kdelgr -n'
alias kdelhr='kdel helmrelease'
alias kdelhrn='kdelhr -n'
alias kdeli='kdel ingress'
alias kdelin='kdeli -n'
alias kdelj='kdel job'
alias kdeljn='kdelj -n'
alias kdelk='kdel kustomization'
alias kdelkn='kdelk -n'
alias kdelns='kdel namespace'
alias kdelpvc='kdel persistentvolumeclaim'
alias kdelpvcn='kdelpvc -n'
alias kdelpv='kdel persistentvolume'
alias kdelpvn='kdelpv -n'
alias kdelp='kdel pod'
alias kdelpn='kdelp -n'
alias kdelrs='kdel replicaset'
alias kdelrsn='kdelrs -n'
alias kdels='kdel secret'
alias kdelsn='kdels -n'
alias kdelsec='kdels'
alias kdelsecn='kdelsec -n'
alias kdelsa='kdel serviceaccount'
alias kdelsan='kdelsa -n'
alias kdelsvc='kdel service'
alias kdelsvcn='kdelsvc -n'
alias kdelss='kdel statefulset'
alias kdelssn='kdelss -n'
alias kdeltf='kdel terraform'
alias kdeltfn='kdeltf -n'

# kubectl describe
alias kd='k describe'
alias kdn='kd -n'
alias kdcr='kd certificaterequest'
alias kdcrn='kdcr -n'
alias kdcj='kd cronjob'
alias kdcjn='kdcj -n'
alias kdc='kd certificate'
alias kdcrn='kdc -n'
alias kdcsr='kd certificatesigningrequest'
alias kdcsrn='kdcsr -n'
alias kdcm='kd configmap'
alias kdcmn='kdcm -n'
alias kdcrd='kd customresourcedefinition'
alias kdcrdn='kdcrd -n'
alias kdds='kd daemonset'
alias kddsn='kdds -n'
alias kdd='kd deployment'
alias kddn='kdd -n'
alias kde='kd endpoint'
alias kden='kde -n'
alias kdes='kd externalsecret'
alias kdesn='kdes -n'
alias kdgr='kd gitrepository'
alias kdgrn='kdgr -n'
alias kdhr='kd helmrelease'
alias kdhrn='kdhr -n'
alias kdi='kd ingress'
alias kdin='kdi -n'
alias kdj='kd job'
alias kdjn='kdj -n'
alias kdk='kd kustomization'
alias kdkn='kdk -n'
alias kdns='kd namespace'
alias kdn='kd node'
alias kdpvc='kd persistentvolumeclaim'
alias kdpvcn='kdpvc -n'
alias kdpv='kd persistentvolume'
alias kdpvn='kdpv -n'
alias kdp='kd pod'
alias kdpn='kdp -n'
alias kdrs='kd replicaset'
alias kdrsn='kdrs -n'
alias kds='kd secret'
alias kdsn='kds -n'
alias kdsec='kds'
alias kdsecn='kdsec -n'
alias kdsa='kd serviceaccount'
alias kdsan='kdsa -n'
alias kdsvc='kd service'
alias kdsvcn='kdsvc -n'
alias kdss='kd statefulset'
alias kdssn='kdss -n'
alias kdtf='kd terraform'
alias kdtfn='kdtf -n'

# kubectl edit
alias ke='k edit'
alias ken='ke -n'
alias kecr='ke certificaterequest'
alias kecrn='kecr -n'
alias kecj='ke cronjob'
alias kecjn='kecj -n'
alias kec='ke certificate'
alias kecn='kec -n'
alias kecsr='ke certificatesigningrequest'
alias kecsrn='kecsr -n'
alias kecm='ke configmap'
alias kecmn='kecm -n'
alias kecrd='ke customresourcedefinition'
alias kecrdn='kecrd -n'
alias keds='ke daemonset'
alias kedsn='keds -n'
alias ked='ke deployment'
alias kedn='ked -n'
alias kee='ke endpoint'
alias keen='kee -n'
alias kees='ke externalsecret'
alias keesn='kees -n'
alias kegr='ke gitrepository'
alias kegrn='kegr -n'
alias kehr='ke helmrelease'
alias kehrn='kehr -n'
alias kei='ke ingress'
alias kein='kei -n'
alias kej='ke job'
alias kejn='kej -n'
alias kek='ke kustomization'
alias kekn='kek -n'
alias kens='ke namespace'
alias kepvc='ke persistentvolumeclaim'
alias kepvcn='kepvc -n'
alias kepv='ke persistentvolume'
alias kepvn='kepv -n'
alias kep='ke pod'
alias kepn='kep -n'
alias kers='ke replicaset'
alias kersn='kers -n'
alias kes='ke secret'
alias kesn='kes -n'
alias kesec='kes'
alias kesecn='kesec -n'
alias kesa='ke serviceaccount'
alias kesan='kesa -n'
alias kesvc='ke service'
alias kesvcn='kesvc -n'
alias kess='ke statefulset'
alias kessn='kess -n'
alias ketf='ke terraform'
alias ketfn='ketf -n'

# kubectl exec
alias keti='k exec -t -i'

# kubectl get
alias kg='k get'
alias kgn='kg -n'
alias kga='kg all'
alias kgaa='ka --all-namespaces'

alias kgcr='kg certificaterequest'
alias kgcrn='kgcr -n'
alias kgcra='kgcr --all-namespaces'
alias kgcrw='kgcr --watch'
alias kgcrwn='kgcrw -n'
alias kgcrwa='kgcrw --all-namespaces'
alias kgcraw='kgcrwa'

alias kgcj='kg cronjob'
alias kgcjn='kgcj -n'
alias kgcja='kgcj --all-namespaces'
alias kgcjw='kgcj --watch'
alias kgcjwn='kgcjw -n'
alias kgcjwa='kgcjw --all-namespaces'
alias kgcjaw='kgcjwa'

alias kgc='kg certificate'
alias kgcn='kgc -n'
alias kgca='kgc --all-namespaces'
alias kgcw='kgc --watch'
alias kgcwn='kgcw -n'
alias kgcwa='kgcw --all-namespaces'
alias kgcaw='kgcwa'

alias kgcsr='kg certificatesigningrequest'
alias kgcsrn='kgcsr -n'
alias kgcsra='kgcsr --all-namespaces'
alias kgcsrw='kgcsr --watch'
alias kgcsrwn='kgcsrw -n'
alias kgcsrwa='kgcsrw --all-namespaces'
alias kgcsrwa='kgcsrw'

alias kgcm='kg configmap'
alias kgcmn='kgcm -n'
alias kgcma='kgcm --all-namespaces'
alias kgcmw='kgcm --watch'
alias kgcmwn='kgcmw -n'
alias kgcmwa='kgcmw --all-namespaces'
alias kgcmaw='kgcmwa'

alias kgcrd='kg customresourcedefinition'
alias kgcrdn='kgcrd -n'
alias kgcrda='kgcrd --all-namespaces'
alias kgcrdw='kgcrd --watch'
alias kgcrdwn='kgcrdw -n'
alias kgcrdwa='kgcrdw --all-namespaces'
alias kgcrdaw='kgcrdwa'

alias kgds='kg daemonset'
alias kgdsn='kgds -n'
alias kgdsa='kgds --all-namespaces'
alias kgdsw='kgds --watch'
alias kgdswn='kgdsw -n'
alias kgdswa='kgdsw --all-namespaces'
alias kgdaw='kgdwa'

alias kgd='kg deployment'
alias kgdn='kgd -n'
alias kgda='kgd --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwn='kgdw -n'
alias kgdwa='kgdw --all-namespaces'
alias kgdaw='kgdwa'

alias kge='kg endpoint'
alias kgen='kge -n'
alias kgea='kge --all-namespaces'
alias kgew='kge --watch'
alias kgewn='kgew -n'
alias kgewa='kgew --all-namespaces'
alias kgeaw='kgewa'

alias kges='kg externalsecret'
alias kgesn='kges -n'
alias kgesa='kges --all-namespaces'
alias kgesw='kges --watch'
alias kgeswn='kgesw -n'
alias kgeswa='kgesw --all-namespaces'
alias kgesaw='kgeswa'

alias kggr='kg gitrepository'
alias kggrn='kggr -n'
alias kggra='kggr --all-namespaces'
alias kggrw='kggr --watch'
alias kggrwn='kggrw -n'
alias kggrwa='kggrw --all-namespaces'
alias kggraw='kggrwa'

alias kghr='kg helmrelease'
alias kghrn='kghr -n'
alias kghra='kghr --all-namespaces'
alias kghrw='kghr --watch'
alias kghrwn='kghrw -n'
alias kghrwa='kghrw --all-namespaces'
alias kghraw='kghrwa'

alias kgi='kg ingress'
alias kgin='kgi -n'
alias kgia='kgi --all-namespaces'
alias kgiw='kgi --watch'
alias kgiwn='kgiw -n'
alias kgiwa='kgiw --all-namespaces'
alias kgiaw='kgiwa'

alias kgj='kg job'
alias kgjn='kgj -n'
alias kgja='kgj --all-namespaces'
alias kgjw='kgj --watch'
alias kgjwn='kgjw -n'
alias kgjwa='kgjw --all-namespaces'
alias kgjaw='kgjwa'

alias kgk='kg kustomization'
alias kgkn='kgk -n'
alias kgka='kgk --all-namespaces'
alias kgkw='kgk --watch'
alias kgkwn='kgkw -n'
alias kgkwa='kgkw --all-namespaces'
alias kgkaw='kgkwa'

alias kgns='kg namespace'
alias kgnsw='kgns --watch'

alias kgno='kg node'
alias kgnodw='kg node --watch'

alias kgpvc='kg persistentvolumeclaim'
alias kgpvcn='kgpvc -n'
alias kgpvca='kgpvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kgpvcwn='kgpvcw -n'
alias kgpvcwa='kgpvcw --all-namespaces'
alias kgpvcaw='kgpvcwa'

alias kgpv='kg persistentvolume'
alias kgpvn='kgpv -n'
alias kgpva='kgpv --all-namespaces'
alias kgpvw='kgpv --watch'
alias kgpvwn='kgpvw -n'
alias kgpvwa='kgpvw --all-namespaces'
alias kgpvaw='kgpvwa'

alias kgp='kg pod'
alias kgpn='kgp -n'
alias kgpa='kgp --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwn='kgpw -n'
alias kgpwa='kgpw --all-namespaces'
alias kgpaw='kgpwa'

alias kgrs='kg replicaset'
alias kgrsn='kgrs -n'
alias kgrsa='kgrs --all-namespaces'
alias kgrsw='kgrs --watch'
alias kgrswn='kgrsw -n'
alias kgrswa='kgrsw --all-namespaces'
alias kgrsaw='kgrswa'

alias kgs='kg secret'
alias kgsn='kgs -n'
alias kgsa='kgs --all-namespaces'
alias kgsw='kgs --watch'
alias kgswn='kgsw -n'
alias kgswa='kgsw --all-namespaces'
alias kgswa='kgsw'

alias kgsec='kgs'
alias kgsecn='kgsec -n'
alias kgseca='kgsec --all-namespaces'
alias kgsecw='kgsec --watch'
alias kgsecwn='kgsecw -n'
alias kgsecwa='kgsecw --all-namespaces'
alias kgsecaw='kgsecwa'

alias kgsa='kg serviceaccount'
alias kgsan='kgsa -n'
alias kgsaa='kgsa --all-namespaces'
alias kgsaw='kgsa --watch'
alias kgsawn='kgsaw -n'
alias kgsawa='kgsaw --all-namespaces'
alias kgsaaw='kgsawa'

alias kgsvc='kg service'
alias kgsvcn='kgsvc -n'
alias kgsvca='kgsvc --all-namespaces'
alias kgsvcw='kgsvc --watch'
alias kgsvcwn='kgsvcw -n'
alias kgsvcwa='kgsvcw --all-namespaces'
alias kgsvcaw='kgsvcwa'

alias kgss='kg statefulset'
alias kgssn='kgss -n'
alias kgssa='kgss --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswn='kgssw -n'
alias kgsswa='kgssw --all-namespaces'
alias kgssaw='kgsswa'

alias kgtf='kg terraform'
alias kgtfn='kgtf -n'
alias kgtfa='kgtf --all-namespaces'
alias kgtfw='kgtf --watch'
alias kgtfwn='kgtfw -n'
alias kgtfwa='kgtfw --all-namespaces'
alias kgtfaw='kgtfwa'

# kubectl logs
alias kl='k logs'
alias kln='kl -n'
alias kl1h='k logs --since 1h'
alias kl1hn='kl1h -n'
alias kl1m='k logs --since 1m'
alias kl1mn='kl1m -n'
alias kl1s='k logs --since 1s'
alias kl1sn='kl1s -n'
alias klf='k logs -f'
alias klfn='klf -n'
alias klf1h='k logs --since 1h -f'
alias klf1hn='klf1h -n'
alias klf1m='k logs --since 1m -f'
alias klf1mn='klf1m -n'
alias klf1s='k logs --since 1s -f'
alias klf1sn='klf1s -n'

# kubectl port-forward
alias kpf='k port-forward'

# kubectl rollout
alias krh='k rollout history'
alias krsd='k rollout status deployment'
alias krsss='k rollout status statefulset'
alias kru='k rollout undo'

# kubectl scale
alias ksd='k scale deployment'
alias ksss='k scale statefulset'

# This doesn't work with kubecolor
alias kw='kubectl watch'


function kgpscn() {
kubectl get pods -n $1 $2 -o go-template \
    --template='{{range .items}}{{"pod: "}}{{.metadata.name}}
{{if .spec.securityContext}}
  PodSecurityContext:
    {{"runAsGroup: "}}{{.spec.securityContext.runAsGroup}}
    {{"runAsNonRoot: "}}{{.spec.securityContext.runAsNonRoot}}
    {{"runAsUser: "}}{{.spec.securityContext.runAsUser}}                                 {{if .spec.securityContext.seLinuxOptions}}
    {{"seLinuxOptions: "}}{{.spec.securityContext.seLinuxOptions}}                       {{end}}
{{else}}PodSecurity Context is not set
{{end}}{{range .spec.containers}}
{{"container name: "}}{{.name}}
{{"image: "}}{{.image}}{{if .securityContext}}
    {{"allowPrivilegeEscalation: "}}{{.securityContext.allowPrivilegeEscalation}}   {{if .securityContext.capabilities}}
    {{"capabilities: "}}{{.securityContext.capabilities}}                           {{end}}
    {{"privileged: "}}{{.securityContext.privileged}}                               {{if .securityContext.procMount}}
    {{"procMount: "}}{{.securityContext.procMount}}                                 {{end}}
    {{"readOnlyRootFilesystem: "}}{{.securityContext.readOnlyRootFilesystem}}
    {{"runAsGroup: "}}{{.securityContext.runAsGroup}}
    {{"runAsNonRoot: "}}{{.securityContext.runAsNonRoot}}
    {{"runAsUser: "}}{{.securityContext.runAsUser}}                                 {{if .securityContext.seLinuxOptions}}
    {{"seLinuxOptions: "}}{{.securityContext.seLinuxOptions}}                       {{end}}{{if .securityContext.windowsOptions}}
    {{"windowsOptions: "}}{{.securityContext.windowsOptions}}                       {{end}}
{{else}}
    SecurityContext is not set
{{end}}
{{end}}{{end}}'
}

## Kubernetes Functions

# Kubectl decrypt secret
function kdecsn() {
  k get secret -n $1 $2 -o json | jq -r '.data | map_values(@base64d)'
}

# Kubectl decrypt secret path
function kdecspn() {
  k get secret -n $1 $2 -o json | jq -r '.data | map_values(@base64d) | .["'$3'"]'
}

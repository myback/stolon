{{/*
Expand the name of the chart.
*/}}
{{- define "stolon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stolon.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stolon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stolon.labels" -}}
helm.sh/chart: {{ include "stolon.chart" . }}
{{ include "stolon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stolon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stolon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "stolon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stolon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
{{ include "stolon.image" ( dict "image" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "stolon.image" -}}
{{- $registryName := default .image.registry .global.imageRegistry -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | toString -}}
{{- if $registryName -}}
{{- $repository = printf "%s/%s" $registryName $repository }}
{{- end -}}
{{- if $tag -}}
{{- $repository = printf "%s:%s" $repository $tag }}
{{- end -}}
{{- $repository -}}
{{- end -}}

{{/*
Return  the proper Storage Class
{{ include "stolon.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "stolon.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "stolon.imagePullSecrets" }}
{{- with (concat .Values.global.imagePullSecrets .Values.stolon.image.pullSecrets | uniq) -}}
imagePullSecrets:
{{- range . }}
- name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "stolon.keeperName" -}}
{{ include "stolon.fullname" . }}-keeper
{{- end -}}

{{- define "stolon.proxyName" -}}
{{- if .Values.proxy.service.name -}}
{{- if contains "." .Values.proxy.service.name -}}
{{- $n := split "." .Values.proxy.service.name -}}
{{ $n._0 }}
{{- else -}}
{{ .Values.proxy.service.name }}
{{- end -}}
{{- else -}}
{{ include "stolon.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "stolon.sentinelName" -}}
{{ include "stolon.fullname" . }}-sentinel
{{- end -}}

{{- define "stolon.configMapConfigsName" -}}
{{ include "stolon.fullname" . }}-configs
{{- end -}}

{{- define "stolon.configMapScripts" -}}
{{ include "stolon.fullname" . }}-scripts
{{- end -}}

{{- define "stolon.configMapEnvsName" -}}
{{ include "stolon.fullname" . }}-envs
{{- end -}}

{{- define "stolon.clusterName" -}}
{{ include "stolon.fullname" . }}-{{ .Release.Namespace }}
{{- end -}}

{{- define "stolon.currentSecretsPath" -}}
{{ .Values.keeper.persistence.path }}/secrets
{{- end -}}

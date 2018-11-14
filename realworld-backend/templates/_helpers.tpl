{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "realworld-backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "realworld-backend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name for the key secret.
*/}}
{{- define "realworld-backend.dbSecret" -}}
    {{- $dbConfig := index .Values "realworld-backend" "dbConfig" -}}
    {{- if $dbConfig.existingDBSecret -}}
        {{- $dbConfig.existingDBSecret -}}
    {{- else -}}
        {{- template "realworld-backend.fullname" . -}}-dbsecret
    {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "realworld-backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Redefine templates from mongodb-replicaset
Workaround for  https://github.com/helm/helm/issues/3920
*/}}

{{- define "realworld-backend.mongodb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mongodb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "realworld-backend.mongodb.adminSecret" -}}
    {{- if .Values.mongodb.auth.existingAdminSecret -}}
        {{- .Values.mongodb.auth.existingAdminSecret -}}
    {{- else -}}
        {{- template "realworld-backend.mongodb.fullname" . -}}-admin
    {{- end -}}
{{- end -}}
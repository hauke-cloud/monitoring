{{/*
Expand the name of the chart.
*/}}
{{- define "monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monitoring.fullname" -}}
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
{{- define "monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monitoring.labels" -}}
helm.sh/chart: {{ include "monitoring.chart" . }}
{{ include "monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "monitoring.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "monitoring.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fullname of a subchart, the way the upstream charts derive it. Takes a dict
with the root context as `ctx`, the subchart's values as `values` and its
chart name as `name`.
*/}}
{{- define "monitoring.subchartFullname" -}}
{{- if .values.fullnameOverride }}
{{- .values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .name .values.nameOverride }}
{{- if contains $name .ctx.Release.Name }}
{{- .ctx.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .ctx.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "monitoring.loki.fullname" -}}
{{- include "monitoring.subchartFullname" (dict "ctx" . "values" .Values.loki "name" "loki") }}
{{- end }}

{{- define "monitoring.tempo.fullname" -}}
{{- include "monitoring.subchartFullname" (dict "ctx" . "values" .Values.tempo "name" "tempo") }}
{{- end }}

{{- define "monitoring.pyroscope.fullname" -}}
{{- include "monitoring.subchartFullname" (dict "ctx" . "values" .Values.pyroscope.pyroscope "name" "pyroscope") }}
{{- end }}

{{- define "monitoring.mimir.fullname" -}}
{{- include "monitoring.subchartFullname" (dict "ctx" . "values" .Values.mimir "name" "mimir") }}
{{- end }}

{{- define "monitoring.alloyReceiver.fullname" -}}
{{- include "monitoring.subchartFullname" (dict "ctx" . "values" (index .Values "alloy-receiver") "name" "alloy") }}
{{- end }}

{{/*
kube-prometheus-stack cuts its fullname at 26 characters before appending the
component, so the Prometheus Service of a release called
`monitoring-monitoring` is `monitoring-monitoring-kube-prometheus`.
*/}}
{{- define "monitoring.prometheus.fullname" -}}
{{- $kps := index .Values "kube-prometheus-stack" }}
{{- if $kps.fullnameOverride }}
{{- $kps.fullnameOverride | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- $name := default "kube-prometheus-stack" $kps.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" }}
{{- end }}
{{- end }}-prometheus
{{- end }}

{{- define "monitoring.loki.url" -}}
http://{{ include "monitoring.loki.fullname" . }}.{{ .Release.Namespace }}.svc:3100
{{- end }}

{{- define "monitoring.tempo.url" -}}
http://{{ include "monitoring.tempo.fullname" . }}.{{ .Release.Namespace }}.svc:3200
{{- end }}

{{- define "monitoring.pyroscope.url" -}}
http://{{ include "monitoring.pyroscope.fullname" . }}.{{ .Release.Namespace }}.svc:4040
{{- end }}

{{- define "monitoring.mimir.url" -}}
http://{{ include "monitoring.mimir.fullname" . }}-gateway.{{ .Release.Namespace }}.svc
{{- end }}

{{/*
Where the receiver remote-writes metrics to. Empty when there is nowhere to
send them, which the callers take as "no metrics pipeline".
*/}}
{{- define "monitoring.metrics.remoteWriteUrl" -}}
{{- $kps := index .Values "kube-prometheus-stack" }}
{{- if .Values.observability.metrics.remoteWriteUrl }}
{{- .Values.observability.metrics.remoteWriteUrl }}
{{- else if .Values.mimir.enabled }}
{{- include "monitoring.mimir.url" . }}/api/v1/push
{{- else if and $kps.prometheus.enabled $kps.prometheus.prometheusSpec.enableRemoteWriteReceiver }}
{{- printf "http://%s.%s.svc:9090/api/v1/write" (include "monitoring.prometheus.fullname" .) .Release.Namespace }}
{{- end }}
{{- end }}

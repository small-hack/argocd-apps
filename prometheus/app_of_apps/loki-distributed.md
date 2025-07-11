apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: loki-distributed-app
  namespace: argocd
spec:
  project: default
  destination:
    server: "https://kubernetes.default.svc"
    namespace: monitoring
  source:
    repoURL: 'https://grafana.github.io/helm-charts'
    chart: loki-distributed
    targetRevision: 0.80.5
    helm:
      version: v3
      skipCrds: true
      valuesObject:
        fullnameOverride: loki-distributed

        serviceAccount:
          create: true

        serviceMonitor:
          enabled: true

        ########################################################################
        #  _          _    _
        # | |    ___ | | _(_)
        # | |   / _ \| |/ / |
        # | |__| (_) |   <| |
        # |_____\___/|_|\_\_|
        ########################################################################
        loki:
          # -- The number of old ReplicaSets to retain to allow rollback
          revisionHistoryLimit: 2

          auth_enabled: false

          existingSecretForConfig: "loki-config"

          pattern_ingester:
            enabled: true

          limits_config:
            allow_structured_metadata: true

          volume_enabled: true

        ########################################################################
        #  ____                                 _
        # / ___|___  _ __ ___  _ __   __ _  ___| |_ ___  _ __
        #| |   / _ \| '_ ` _ \| '_ \ / _` |/ __| __/ _ \| '__|
        #| |__| (_) | | | | | | |_) | (_| | (__| || (_) | |
        # \____\___/|_| |_| |_| .__/ \__,_|\___|\__\___/|_|
        #                     |_|
        ########################################################################
        compactor:
          enabled: true

          serviceAccount:
            create: true

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

          kind: StatefulSet

          replicas: 1

          persistence:
            enabled: true
            size: 32Gi
            storageClass: local-path
            enableStatefulSetAutoDeletePVC: false
            whenDeleted: Retain
            whenScaled: Retain

        ########################################################################
        #   ____       _
        #  / ___| __ _| |_ _____      ____ _ _   _
        # | |  _ / _` | __/ _ \ \ /\ / / _` | | | |
        # | |_| | (_| | ||  __/\ V  V / (_| | |_| |
        #  \____|\__,_|\__\___| \_/\_/ \__,_|\__, |
        #                                    |___/
        ########################################################################
        gateway:
          enabled: true

          replicas: 1

          autoscaling:
            enabled: false

          affinity: {}

          service:
            port: 80
            type: ClusterIP

          ingress:
            enabled: false

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        ########################################################################
        #  __  __                               _              _
        # |  \/  | ___ _ __ ___   ___ __ _  ___| |__   ___  __| |
        # | |\/| |/ _ \ '_ ` _ \ / __/ _` |/ __| '_ \ / _ \/ _` |
        # | |  | |  __/ | | | | | (_| (_| | (__| | | |  __/ (_| |
        # |_|  |_|\___|_| |_| |_|\___\__,_|\___|_| |_|\___|\__,_|
        ########################################################################
        memcachedchunks:
          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        memcachedfrontend:
          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        ########################################################################
        #  ____  _     _        _ _           _
        # |  _ \(_)___| |_ _ __(_) |__  _   _| |_ ___  _ __
        # | | | | / __| __| '__| | '_ \| | | | __/ _ \| '__|
        # | |_| | \__ \ |_| |  | | |_) | |_| | || (_) | |
        # |____/|_|___/\__|_|  |_|_.__/ \__,_|\__\___/|_|
        ########################################################################
        distributor:
          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

          replicas: 1

          autoscaling:
            enabled: false

          affinity: {}

          resources: {}

        ########################################################################
        #  ___                       _
        # |_ _|_ __   __ _  ___  ___| |_ ___ _ __
        #  | || '_ \ / _` |/ _ \/ __| __/ _ \ '__|
        #  | || | | | (_| |  __/\__ \ ||  __/ |
        # |___|_| |_|\__, |\___||___/\__\___|_|
        #            |___/
        ########################################################################
        ingester:
          kind: StatefulSet

          autoforget_unhealthy: true

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

          wal:
            enabled: false

          resources:
            requests:
              cpu: 250m
              memory: 1024Mi
            limits:
              cpu: 2
              memory: 4096Mi

          autoscaling:
            enabled: true
            minReplicas: 2
            maxReplicas: 3
            targetCPUUtilizationPercentage: 60
            targetMemoryUtilizationPercentage: 70
            behavior:
              enabled: false
              scaleDown: {}
              scaleUp: {}

          topologySpreadConstraints: {}

          affinity: ""

          persistence:
            enabled: false

        ########################################################################
        #   ___           _              ____       _
        #  |_ _|_ __   __| | _____  __  / ___| __ _| |_ _____      ____ _ _   _
        #   | || '_ \ / _` |/ _ \ \/ / | |  _ / _` | __/ _ \ \ /\ / / _` | | | |
        #   | || | | | (_| |  __/>  <  | |_| | (_| | ||  __/\ V  V / (_| | |_| |
        #  |___|_| |_|\__,_|\___/_/\_\  \____|\__,_|\__\___| \_/\_/ \__,_|\__, |
        #                                                                 |___/
        ########################################################################
        indexGateway:
          enabled: true

          replicas: 1

          affinity: {}

          resources: {}

          persistence:
            enabled: true
            inMemory: false
            size: 10Gi
            storageClass: local-path
            enableStatefulSetAutoDeletePVC: false
            whenDeleted: Retain
            whenScaled: Retain

        ########################################################################
        #   ___                  _
        #  / _ \ _   _  ___ _ __(_) ___ _ __
        # | | | | | | |/ _ \ '__| |/ _ \ '__|
        # | |_| | |_| |  __/ |  | |  __/ |
        #  \__\_\\__,_|\___|_|  |_|\___|_|
        ########################################################################
        querier:
          replicas: 1

          autoscaling:
            enabled: false

          resources: {}

          topologySpreadConstraints: ""

          affinity: {}

          persistence:
            enabled: true
            size: 10Gi
            storageClass: local-path

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        ########################################################################
        #   ___    _____                _                 _
        #  / _ \  |  ___| __ ___  _ __ | |_ ___ _ __   __| |
        # | | | | | |_ | '__/ _ \| '_ \| __/ _ \ '_ \ / _` |
        # | |_| | |  _|| | | (_) | | | | ||  __/ | | | (_| |
        #  \__\_\ |_|  |_|  \___/|_| |_|\__\___|_| |_|\__,_|
        ########################################################################
        queryFrontend:
          replicas: 1

          autoscaling:
            enabled: false

          affinity: {}

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        ########################################################################
        #   ___    ____       _              _       _
        #  / _ \  / ___|  ___| |__   ___  __| |_   _| | ___ _ __
        # | | | | \___ \ / __| '_ \ / _ \/ _` | | | | |/ _ \ '__|
        # | |_| |  ___) | (__| | | |  __/ (_| | |_| | |  __/ |
        #  \__\_\ |____/ \___|_| |_|\___|\__,_|\__,_|_|\___|_|
        ########################################################################
        queryScheduler:
          enabled: false

          replicas: 2

          affinity: {}

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

        ########################################################################
        #  ____        _
        # |  _ \ _   _| | ___ _ __
        # | |_) | | | | |/ _ \ '__|
        # |  _ <| |_| | |  __/ |
        # |_| \_\\__,_|_|\___|_|
        #
        ########################################################################
        ruler:
          enabled: true

          kind: Deployment

          replicas: 1

          affinity: {}

          extraArgs:
            - -memberlist.bind-addr=$(MY_POD_IP)

          extraEnv:
            - name: MY_POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP

          resources: {}

          persistence:
            enabled: true
            size: 10Gi
            storageClass: local-path

          extraContainers:
            - name: load-rule-configmaps
              image: kiwigrid/k8s-sidecar:1.19.5
              imagePullPolicy: IfNotPresent

              volumeMounts:
                - name: fake
                  mountPath: /etc/loki/rules/fake/

              env:
                - name: LABEL
                  value: "loki-ruler-alerts"

                - name: FOLDER
                  value: /etc/loki/rukles/fake

                - name: RESOURCE
                  value: configmap

          extraVolumes:
            - name: fake
              emptyDir: {}

          extraVolumeMounts:
            - name: fake
              mountPath: /etc/loki/rules/fake

  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
    automated:
      selfHeal: true

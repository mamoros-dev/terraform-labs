# LAB 11: Automatización con Webhooks de GitHub y Jenkins

```bash
+---------------------------------------------------------------------------------------------------+
|                           FLUJO AUTOMATIZADO CON GITHUB WEBHOOKS & JENKINS                        |
+---------------------------------------------------------------------------------------------------+

   [ Desarrollador / Tu Git ] 
               │
               ├── ( `git push` ) ──► [ Repositorio en GitHub ]
               │                                │
               │                                │ (Dispara Webhook HTTP POST)
               │                                ▼
               │                     [ Tu Jenkins Local (Puerto 8080) ]
               │                                │
               │                                │ (Clona, compila y construye)
               ▼                                ▼
     [ Rama Dedicada Lab 11 ] ──────► [ Pipeline Automático en Verde ]
```

## Table of contents

- [Ejercicio](#ejercicio)
- [Instalacion Jenkins](#instalacion-jenkins)
- [Jenkinsfile](#jenkinsfile)
- [Pipeline real](#pipeline-real)
- [Pipeline con parametros y credenciales](#pipeline-con-parametros-y-credenciales)
- [Pipeline con Control de Errores y Entornos](#pipeline-con-control-de-errores-y-entornos)
- [Resumen](#resumen)
- [Chuleta](#chuleta)
- [Author](#author)

## Ejercicio

+ Una vez que ya sabemos programar pipelines robustos en Jenkins de forma manual, el siguiente paso natural en una empresa es eliminar la intervención humana.
+ En el Lab 11 aprenderemos a:
    - Configurar un Webhook en tu repositorio de GitHub para que avise a tu Jenkins local cada vez que hagas un git push.
    - Configurar la autenticación segura (Tokens de acceso personal / SSH Keys) para que Jenkins descargue automáticamente el código de tu rama.
    - Disparar el build de forma totalmente autónoma.

+ **Instalar el plugin de GitHub en Jenkins:**  
    - Para que Jenkins sepa entender los eventos de GitHub, asegúrate de tener el plugin instalado:Entra en tu panel de Jenkins (http://localhost:8080).
    - Ve a Manage Jenkins (Gestionar Jenkins) > Plugins > Available plugins.
    - Busca GitHub Integration o GitHub Plugin, márcalo y pulsa Install (instalar sin reiniciar).


+ **Crear un Pipeline basado en SCM (Git):**  
    - En lugar de escribir el código directamente en la interfaz de Jenkins, ahora le diremos a Jenkins que lea el Jenkinsfile directamente de tu repositorio de Git:
        + Crea un archivo llamado Jenkinsfile en la raíz de tu proyecto local con el código robusto que hicimos en el Lab 10.
        + Haz commit y push de esta rama a tu GitHub (git push origin feature/lab11-webhooks-github).En Jenkins, crea un New Item de tipo Pipeline, llámale pipeline-github-sincronizado.
        + En la configuración del job, baja hasta la sección Pipeline:
            - En Definition, cambia a Pipeline script from SCM.
            - En SCM, selecciona Git.
            - En Repository URL, pega la URL de tu repositorio de GitHub (ej: https://github.com/mamoros-dev/tu-repo.git
            - En Branch Specifier, pon */feature/lab11-webhooks-github.
            - En Script Path, deja Jenkinsfile.
        + Pulsa Save.

+ **Configurar el disparador de Webhook (Build triggers):**  
    - En la configuración de ese mismo job en Jenkins:
        + Busca la sección Build Triggers (Disparadores de construcción).
        + Marca la casilla GitHub hook trigger for GITScm polling.
        + Esto le indica a Jenkins que quede a la escucha de las notificaciones silenciosas que lleguen desde GitHub.


## Webhook en GitHub
+ Para que GitHub sepa la dirección de tu Jenkins:
    - Vas a tu repositorio en la web de GitHub -> Settings (Configuración) -> Webhooks -> Add webhook.
    - En Payload URL, normalmente se pondría la IP pública de tu servidor Jenkins seguida de /github-webhook/ (por ejemplo: http://<tu-ip-publica>:8080/github-webhook/).
> Nota para entorno local: Como estás en local, si no usas una herramienta de túnel como ngrok para exponer tu puerto 8080 a internet, GitHub no podrá hacer ping a tu localhost. ¡Pero no te preocupes! En los entornos de producción reales corporativos, Jenkins está desplegado en servidores internos con IP alcanzable o tras un balanceador con dominio propio.


## Author
+ Miguel — [GitHub](https://github.com/mamoros-dev) · [LinkedIn](https://www.linkedin.com/in/miguel-amoros-moret/)

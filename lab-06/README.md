# LAB 6: GitHub Actions para Lint y Tests en Pull Requests

![](./images/arquitectura.png)  



## Table of contents

- [Ejercicio](#ejercicio)
- [Comandos CLI Terraform Workspaces](#comandos-cli-terraform-workspaces)
- [Configuracion de backend y providers](#configuracion-de-backend-y-providers)
- [Configuracion de variables](#configuracion-de-variables)
- [Main con for each](#main-con-for-each)
- [Modulo Local con Bloques dynamic](#modulo-local-con-bloques-dynamic)
- [Verificacion](#verificacion)
- [Author](#author)

## Ejercicio

+ Configuraremos un workflow de GitHub Actions que se activará automáticamente cada vez que alguien abra o actualice una Pull Request (PR) hacia la rama principal (main).
+ Este pipeline ejecutará tres validaciones clave:
    - Formatting (terraform fmt): Comprueba que el código siga el formato estándar de HCL.
    - Initialization (terraform init): Descarga los proveedores y verifica la estructura.
    - Validation (terraform validate): Revisa la sintaxis interna y la coherencia de las referencias/variables.
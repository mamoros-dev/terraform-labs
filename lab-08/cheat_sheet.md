# Command Cheat Sheet (Chuleta de Comandos Cisco)

| Operation | Command | Description |
| :--- | :--- | :--- |
| **Enable Privileged Mode** | `enable` | Switches from user mode to privileged mode. |
| **Global Configuration** | `configure terminal` | Enters global configuration mode. |
| **Create VLAN** | `vlan {ID}` + `name {NAME}` | Creates a VLAN and assigns a descriptive name. |
| **Trunk Port Setup** | `switchport mode trunk` | Forces a port into 802.1Q trunking mode. |
| **Access Port Setup** | `switchport mode access` + `switchport access vlan {ID}` | Assigns a port to a specific VLAN. |
| **Range Configuration** | `interface range fastEthernet 0/2 - 24` | Configures multiple interfaces simultaneously. |
| **Enable Routing (L3)** | `ip routing` | Enables IP routing capability on Multilayer switches. |
| **Routed Port (L3)** | `no switchport` + `ip address ...` | Converts a switch port into a routed Layer 3 port. |
| **Static Route** | `ip route {DEST} {MASK} {NEXT-HOP}` | Adds a static route to the routing table. |
| **Verify Interfaces** | `show ip interface brief` | Lists all interfaces, IP status, and line protocols. |
| **Verify Routing Table** | `show ip route` | Displays active routes, connected subnets, and gateways. |
| **Verify Trunks** | `show interfaces trunk` | Displays active trunk ports and allowed VLANs. |
| **Verify VLAN Database**| `show vlan brief` | Lists VLAN assignments across all switch ports. |
| **Save Configuration** | `write` (or `copy running-config startup-config`) | Saves current configuration to NVRAM. |


# Referencia de Comandos de Routing y Switching: Fuentes para Cuaderno

Este documento clasifica los comandos esenciales de Cisco IOS en español según su función operativa, optimizado para ser utilizado como fuente de referencia en cuadernos y notas técnicas.

## 1. Configuración Inicial y Gestión de Dispositivos

* **`enable`**
  * *Función:* Eleva el modo de ejecución de usuario al modo EXEC privilegiado (`#`).

* **`configure terminal`**
  * *Función:* Accede al modo de configuración global desde el modo privilegiado para modificar ajustes del dispositivo.

* **`hostname {NOMBRE}`**
  * *Función:* Asigna un identificador o nombre único al dispositivo de red.

* **`write`** (o **`copy running-config startup-config`**)
  * *Función:* Guarda la configuración activa actual desde la memoria RAM hacia la NVRAM para que persista tras reiniciar.

## 2. Switching de Capa 2 y Gestión de VLANs

* **`vlan {ID}`**
  * *Función:* Crea o modifica una Red de Área Local Virtual (VLAN) específica en la base de datos del switch.

* **`name {TEXTO}`**
  * *Función:* Asigna una etiqueta o nombre descriptivo a una VLAN activa.

* **`switchport mode access`**
  * *Función:* Configura un puerto de switch para que actúe como puerto de acceso, conectando dispositivos finales en una única VLAN.

* **`switchport access vlan {ID}`**
  * *Función:* Asigna un puerto de acceso de forma explícita a un ID de VLAN determinado.

* **`switchport mode trunk`**
  * *Función:* Fuerza a una interfaz a operar como un enlace troncal (Trunk) 802.1Q para transportar múltiples VLANs simultáneamente.

* **`interface range {RANGO_INTERFACES}`**
  * *Función:* Permite configurar múltiples interfaces físicas o lógicas de forma simultánea (ej. `interface range fastEthernet 0/2 - 24`).

## 3. Enrutamiento de Capa 3 y Switches Multicapa

* **`ip routing`**
  * *Función:* Habilita de forma activa el enrutamiento de paquetes IP de Capa 3 en un Switch Multicapa.

* **`interface vlan {ID}`**
  * *Función:* Crea una interfaz virtual de switch (SVI) para que actúe como puerta de enlace predeterminada (*Gateway*) de una VLAN específica.

* **`no switchport`**
  * *Función:* Convierte un puerto físico de switch en un puerto de Capa 3 puramente enrutado.

* **`ip address {IP} {MASCARA}`**
  * *Función:* Asigna una dirección IPv4 y su máscara de subred a una interfaz física o virtual.

* **`ip route {RED_DESTINO} {MASCARA} {IP_SIGUIENTE_SALTO}`**
  * *Función:* Añade una entrada de ruta estática a la tabla de enrutamiento del dispositivo.

* **`ip route 0.0.0.0 0.0.0.0 {IP_SALTO}`**
  * *Función:* Configura una ruta por defecto (*Gateway of Last Resort*) para todo el tráfico saliente no mapeado.

## 4. Seguridad y Listas de Control de Acceso (ACLs)

* **`access-list {ID} {deny|permit} {protocolo} {origen} {destino}`**
  * *Función:* Define una regla de Lista de Control de Acceso para filtrar tráfico basándose en direcciones IP, redes o puertos específicos.

* **`ip access-group {ID} {in|out}`**
  * *Función:* Aplica un filtro de ACL establecido directamente sobre una interfaz en dirección de entrada (`in`) o salida (`out`).

## 5. Verificación y Diagnóstico (*Troubleshooting*)

* **`show ip interface brief`**
  * *Función:* Muestra una tabla resumen de todas las interfaces físicas y virtuales, sus IPs asignadas y su estado operativo (`up/down`).

* **`show ip route`**
  * *Función:* Muestra la tabla de enrutamiento activa, incluyendo redes conectadas directamente (`C`), rutas estáticas (`S`) y la pasarela por defecto.

* **`show vlan brief`**
  * *Función:* Muestra las asignaciones de VLAN, su estado activo y la pertenencia de los puertos en el switch.

* **`show interfaces trunk`**
  * *Función:* Verifica los enlaces troncales activos, tipos de encapsulación, VLANs permitidas y estados de reenvío.

* **`show spanning-tree`**
  * *Función:* Inspecciona el estado del protocolo Spanning Tree, prioridades de puentes raíz, roles de puerto (`Root`, `Designated`) y estados (`FWD`, `BLK`).

* **`show access-lists`**
  * *Función:* Muestra las reglas de ACL activas y los contadores de coincidencia de tráfico en el dispositivo.
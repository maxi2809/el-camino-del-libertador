# 🏔️ EL CAMINO DEL LIBERTADOR — Game Design Document

| Ficha | |
|---|---|
| **Estudio** | Vela Studios |
| **Género** | Educativo / casual (2D) |
| **Plataforma** | Windows (PC) |
| **Motor** | Godot 4.7 — Forward Plus (D3D12) |
| **Resolución** | 1280 × 720 |
| **Idioma** | Español |
| **Versión del documento** | 1.0 — acompaña la Demo v0.1.0 |
| **Distribución** | GitHub Releases — [el-camino-del-libertador](https://github.com/maxi2809/el-camino-del-libertador) |

---

## 1. Visión general

*El Camino del Libertador* es un juego educativo que revive la gesta del
**Ejército de los Andes (1817)**. El jugador encarna a un joven granadero que,
bajo el mando del **General José de San Martín**, se prepara en el campamento
de El Plumerillo para el cruce de la cordillera: explora, supera retos,
recibe medallas y asciende de rango hasta ser reconocido en el **Museo del
Libertador**.

### Fantasy del jugador
> *"Soy un granadero del Ejército de los Andes: cada suministro que atrapo,
> cada pregunta que respondo y cada carta que emparejo me acerca a la
> honra de Granadero Honorario."*

### Pilares de diseño
1. **Educativo con corazón** — la historia enseña; el juego motiva.
2. **Siempre hacia adelante** — no hay castigo que frene: los fallos invitan a reintentar.
3. **Identidad histórica respetada** — paleta, arte y tono del GDD original.
4. **Progresión visible** — rangos, medallas y ceremonias celebran cada logro.

## 2. Contexto histórico

- **El Plumerillo (Mendoza, 1816–1817)**: campamento donde San Martín entrenó al Ejército de los Andes.
- **Enero de 1817**: inicio del cruce de la cordillera por los pasos de Uspallata y Los Patos, con miles de mulas y caballos.
- **12 de febrero de 1817**: Batalla de Chacabuco, primera gran victoria en Chile.
- **Plan continental**: liberar Chile y llegar por mar al Perú.
- **Proclama**: *"Los hombres libres de América empiezan hoy una nueva carrera…"* (usada en el cierre del GDD).

## 3. Core loop

```
        ┌──────────────────────────────────────────────┐
        ▼                                              │
   EXPLORAR ──► RETOS ──► RECOMPENSAS ──► AVANZAR ─────┘
  (moverse,     (nivel o   (puntos,      (ascenso de
   conocer)      minijuego) medallas)     rango y nueva misión)
```

El loop se cierra en la **meta final del GDD**: el Museo del Libertador,
donde la campaña completa se convierte en recorrido, rango y ceremonia.

## 4. Progresión y rangos

Cada reto completado incrementa `completed_minigames` (GameManager) y dispara
`check_promotion()`:

| Retos completados | Rango | Medallas |
|:---:|---|:---:|
| Inicio | RECLUTA | ⭐ |
| 1 | SOLDADO | ⭐⭐ |
| 2 | CABO | ⭐⭐⭐ |
| 3 | SARGENTO | ⭐⭐⭐⭐ |
| 4 | GRANADERO HONORARIO DEL EJÉRCITO DE LOS ANDES | ⭐⭐⭐⭐⭐ |

Cada ascenso muestra la **pantalla de promoción**: nombre del jugador, título
de rango, estrellas, retrato oficial y **medalla de reconocimiento**.

## 5. Flujo de campaña

```
Splash (sting sincronizado) → Login → Creación de avatar
  → Diálogo con San Martín
  → N1 Campamento del Plumerillo ──► ⭐ SOLDADO
  → N2 Consejo del Saber ──────────► ⭐⭐ CABO
  → N3 Desafío de memoria ─────────► ⭐⭐⭐ SARGENTO
  → N4 (Misión 4 — por diseñar) ───► ⭐⭐⭐⭐⭐ GRANADERO HONORARIO
  → MUSEO DEL LIBERTADOR (meta final) → "Volver al inicio" reinicia
```

## 6. Misiones

### 🏕️ Nivel 1 — Campamento del Plumerillo *(implementado)*
- **Mecánica**: atrapar suministros que caen desde la parte superior en
  posiciones X aleatorias, moviendo al granadero con **← → / A–D**.
- **Consigna**: 5 de cada suministro — *Poncho Cordillerano, Pólvora Seca,
  Charqui* (15 en total) en **90 segundos**.
- **Reglas**:
  - El ítem que toca el suelo **no se pierde**: vuelve a la lista y cae de nuevo.
  - El tiempo restante se pone **rojo** en los últimos 15 s.
  - Victoria: video del **logro obtenido** en bucle + «Continuar».
  - Derrota (tiempo agotado): **mensaje flotante motivador** («El granadero
    no se rinde…») + botón **«Jugar nuevamente»**.
- **Feedback**: contador por ítem (badges dorados), texto flotante «+1 …»,
  salto de celebración del avatar.
- **Parámetros exportables**: `required_per_item` (5), `game_time` (90),
  `fall_speed_min/max` (200–330 px/s).

### 📜 Nivel 2 — Consejo del Saber *(implementado)*
- **Mecánica**: trivia histórica, 6 preguntas con 4 opciones (A–D).
- **Puntaje**: 10 por acierto; la correcta se pinta **verde**, la elegida
  errónea **roja**, y se revela un **dato histórico**.
- **Contenidos**: liderazgo de San Martín · año del cruce (1817) · El
  Plumerillo/Mendoza · mulas y caballos · Batalla de Chacabuco (12/02/1817) ·
  plan continental (liberar Chile y llegar a Perú).
- **Cierre**: video del logro + «Recibir mi ascenso».

### 🃏 Nivel 3 — Desafío de memoria histórica *(implementado)*
- **Mecánica**: memorama 4×4 con **reversos del mosaico del logo oficial**.
- **HUD**: puntaje animado y tiempo (rojo en los últimos 10 s), grilla centrada.

### 🗺️ Nivel 4 — *(por diseñar)*
Cuarto reto del mapa de campaña para alcanzar el rango **GRANADERO
HONORARIO**. Candidatos del GDD: el orden de la marcha por los pasos
(organización de columnas) o una travesía por la cordillera evitando
riesgos. Queda reservado en `check_promotion()` (caso `4`).

### 🏛️ Meta final — Museo del Libertador *(implementado)*
- **Video de la ceremonia de entrega del diploma** como pieza central (640×360, en bucle).
- **Logo del juego de fondo** (atenuado al 15 %), sin recuadros con bordes.
- Debajo del video: **TU RECORRIDO** (✔ por misión), **TU RANGO**
  (nombre, título, estrellas) y **ESTADÍSTICAS** (puntaje total, misiones).
- **«Volver al inicio»** reinicia la campaña (UserData + GameManager).

## 7. Personalización del avatar

- **5 granaderos** con uniforme de gala completo: *Castaño clásico, Rizos del
  ejército, Rubio cordillerano, Pelirrojo valiente, Granadero audaz*.
- La elección (`UserData.avatar_skin`) se refleja en el diálogo introductorio
  y en el token del Nivel 1.
- El **nombre del jugador** se ingresa en el login (Enter incluido) y aparece
  en ascensos y museo.

## 8. UI / UX

- **Tema global** (`theme/main_theme.tres`): labels marfil 22 px con sombra
  suave, botones dorados redondeados, campos de texto con foco dorado.
- **Textos grandes y legibles** (títulos 30–40 px).
- **Consignas explícitas** al iniciar cada nivel, que se desvanecen solas.
- **Mensajes motivadores** en la derrota; reintentos ilimitados; sin game over punitivo.

## 9. Arte e identidad visual

| Elemento | Definición |
|---|---|
| Azul Noche | `#111931` — fondos, cielo |
| Oro Libertador | `#D9A441` — títulos, bordes, botones, medallas |
| Marfil Histórico | `#F2E8D5` — textos sobre azul |
| Tipografías | Cinzel (títulos), Montserrat (UI), Nunito (cuerpo) — pendiente de instalación |

- Arte oficial extraído de la guía de marca del GDD (diploma, medalla,
  retratos de rango, tarjetas).
- **Badges de coleccionables** con íconos propios (poncho, barril de pólvora,
  charqui) en azules y borde dorado.
- Animaciones: trote del avatar, saltos de celebración, tweens de UI.

## 10. Audio

- **Splash**: sting sincronizado a su duración (~9,6 s) con fade-out al salir.
- **Banda sonora global**: autoload `MusicPlayer` arranca al finalizar el splash y continúa en bucle en todas las escenas.
- Proyecto musical editable en `song/` (REAPER).

## 11. Arquitectura técnica

- **Autoloads**: `UserData` (nombre, avatar), `GameManager` (rango, retos,
  puntaje, ascensos, `reset()`), `MusicPlayer` (música global).
- **Escenas clave**: `Splash`, `LoginUI`, `AvatarCreation`,
  `IntroSanMartinDialogue`, `Level1_Plumerillo` (+`PlayerToken`,
  `Collectible`, `Level1Manager`), `Level2_Consejo` (+`Level2Manager`),
  `minigames/memory_challenge/Main`, `LevelCompleteScreen`,
  `MuseoDelLibertador`.
- **Patrones**: señales con `CONNECT_DEFERRED` para colecciones físicas,
  `call_deferred` fuera del flush de input, tweens con guardas de solapamiento.
- **Video**: OGV/Theora (formato nativo de Godot) — `logro_obtenido.ogv`,
  `entrega_diploma.ogv`.
- **Export**: Windows Desktop, PCK embebido, compartido vía GitHub Releases
  (los `.exe`/`.pck` no se versionan).

## 12. Roadmap

| Prioridad | Ítem |
|:---:|---|
| Alta | Misión 4 → rango **GRANADERO HONORARIO** alcanzable |
| Alta | Persistencia de progreso en `user://` (JSON) |
| Media | Tipografías Cinzel/Montserrat/Nunito como tema global |
| Media | Capturas reales de gameplay en el README |
| Baja | Ajuste de dificultad por selectividad (tiempo/velocidad) |
| Baja | Versión para más plataformas (Linux/macOS) |

## 13. Referencias

- Game Design Document original de **Vela Studios** — *El Camino del Libertador* (PDF).
- Historia: Ejército de los Andes, El Plumerillo, cruce de la cordillera
  (1817), Batalla de Chacabuco.
- Repositorio: <https://github.com/maxi2809/el-camino-del-libertador>

# Documentación de Very Good Game Template

## Tabla de Contenidos

### Fundamentos

1. [Estructura General del Proyecto](#1-estructura-general-del-proyecto)
2. [Estructura de lib/](#2-estructura-de-lib)
3. [Capas de Abstracción](#3-capas-de-abstracción)
4. [Organización de Módulos Especializados](#4-organización-de-módulos-especializados)
5. [Sistema de Exportaciones (Barrels)](#5-sistema-de-exportaciones-barrels)

### Testing y Calidad

6. [Estructura de Tests](#6-estructura-de-tests)
7. [Gestión de Dependencias](#7-gestión-de-dependencias)
8. [Convenciones de Nombre](#8-convenciones-de-nombre)
9. [Buenas Prácticas](#9-buenas-prácticas)
10. [Análisis de Código y Linting](#10-análisis-de-código-y-linting)

### Arquitectura y Patrones

11. [Ciclo de Vida de la Aplicación](#11-ciclo-de-vida-de-la-aplicación)
12. [Patrones de Comunicación](#12-patrones-de-comunicación)
13. [Características Especiales de Flame](#13-características-especiales-de-flame)
14. [Recursos y Assets](#14-recursos-y-assets)
15. [Flujo de Trabajo del Desarrollador](#15-flujo-de-trabajo-del-desarrollador)
16. [Ventajas de la Plantilla](#16-ventajas-de-la-plantilla)

### Arquitectura Avanzada

17. [Patrones de Inyección de Dependencias](#17-patrones-de-inyección-de-dependencias)
18. [Estructura del Widget Raíz](#18-estructura-del-widget-raíz)
19. [Gestión de Temas y Configuración Global](#19-gestión-de-temas-y-configuración-global)
20. [Generación de Código Automático](#20-generación-de-código-automático)
21. [Navegación en Very Good Game Template](#21-navegación-en-very-good-game-template)

### Performance y Optimización

22. [Rendimiento y Optimizaciones](#22-rendimiento-y-optimizaciones)
23. [Manejo de Errores y Excepciones](#23-manejo-de-errores-y-excepciones)

### DevOps y Escalabilidad

24. [Integración Continua y Deployment](#24-integración-continua-y-deployment)
25. [Escalabilidad del Proyecto](#25-escalabilidad-del-proyecto)
26. [Mejores Prácticas de Colaboración](#26-mejores-prácticas-de-colaboración)

### Patrones Específicos

27. [Patrón de Behaviors en Flame (Profundizado)](#27-patrón-de-behaviors-en-flame-profundizado)
28. [Testing de Componentes Flame](#28-testing-de-componentes-flame)
29. [Gestión de Audio y Sonido](#29-gestión-de-audio-y-sonido)
30. [Patrones de Estados Complejos](#30-patrones-de-estados-complejos)

### Decisiones y Antipatrones

31. [Decisiones de Arquitectura](#31-decisiones-de-arquitectura)
32. [Antipatrones Comunes a Evitar](#32-antipatrones-comunes-a-evitar)

### Mantenimiento

33. [Migración y Evolución del Código](#33-migración-y-evolución-del-código)
34. [Debugging y Troubleshooting](#34-debugging-y-troubleshooting)
35. [Recursos y Aprendizaje Continuo](#35-recursos-y-aprendizaje-continuo)

---

## Introducción

Very Good Game Template es una plantilla de Flutter especializada en desarrollo de juegos con Flame. Esta plantilla implementa arquitectura limpia, patrones de diseño robustos y convenciones de código que fomentan la mantenibilidad, testabilidad y escalabilidad de proyectos de juegos.

---

## 1. Estructura General del Proyecto

### Filosofía de Organización

La plantilla sigue el principio de **separación de responsabilidades** mediante capas bien definidas:

- **lib/**: Contiene la lógica principal de la aplicación
- **test/**: Espejo de la estructura `lib/` con tests correspondientes
- **assets/**: Recursos estáticos (audio, imágenes, licencias)
- **Plataformas específicas**: `android/`, `ios/`, `macos/`, `windows/`, `web/`

### Principios Clave

1. **Modularidad**: Cada funcionalidad está encapsulada en su propio módulo
2. **Escalabilidad**: Fácil agregar nuevas características sin afectar el código existente
3. **Testabilidad**: Estructura diseñada para permitir testing exhaustivo
4. **Claridad**: Nombres y ubicaciones de archivos comunican claramente su propósito

---

## 2. Estructura de `lib/`

### Nivel Superior: Carpetas Funcionales

La carpeta `lib/` se divide en módulos funcionales independientes:

```text
lib/
├── bootstrap.dart           # Inicialización de la aplicación
├── main_*.dart             # Puntos de entrada para diferentes flavores
├── app/                    # Configuración de la aplicación
├── game/                   # Lógica principal del juego
├── loading/                # Pantalla de carga
├── title/                  # Pantalla de título
├── gen/                    # Código generado automáticamente
└── l10n/                   # Localización e internacionalización
```

### Concepto: Módulo Funcional

Un módulo funcional es una carpeta temática que agrupa:

- **cubit/**: Lógica de estado y eventos
- **view/**: Componentes visuales y páginas
- **widgets/**: Componentes reutilizables (si aplica)
- **entities/**: Modelos de datos y entidades del dominio

### Bootstrap

El archivo `bootstrap.dart` es el punto de inicialización de la aplicación:

- Configura observadores de Bloc para logging
- Maneja errores globales
- Registra licencias de activos
- Prepara la aplicación antes de renderizar

**Patrón**: Se espera que el bootstrap sea llamado desde `main_*.dart` con una función builder que retorna el widget raíz.

### Flavores

Los archivos `main_development.dart`, `main_staging.dart` y `main_production.dart` permiten diferentes configuraciones por entorno:

- Diferente lógica de inicialización
- Diferentes configuraciones de servicios
- Diferente logging y debugging

**Patrón**: Cada main importa el bootstrap y pasa su propia configuración específica del entorno.

---

## 3. Capas de Abstracción

### 3.1 Capa de Presentación (View)

**Ubicación**: `lib/[modulo]/view/`

**Responsabilidades**:

- Renderizar widgets en pantalla
- Responder a eventos del usuario
- Consumir estado de Cubits via BlocListener/BlocBuilder
- Mantener lógica UI mínima

**Patrón de Página**:

- Las páginas son `StatefulWidget` o `StatelessWidget`
- Utilizan `BlocProvider` para inyectar dependencias
- Utilizan `BlocListener` para reaccionar a cambios de estado
- Utilizan `BlocBuilder` para reconstruir según estado

### 3.2 Capa de Lógica de Negocio (Cubit)

**Ubicación**: `lib/[modulo]/cubit/`

**Responsabilidades**:

- Manejar lógica de estado
- Encapsular cambios de estado
- Exponer métodos para interacciones del usuario
- Orquestar operaciones asincrónicas

**Patrón de Cubit**:

- Hereda de `Cubit<State>`
- Emite estados nuevos con `emit()`
- Métodos públicos para eventos/comandos
- Gestiona ciclo de vida con `close()`

**Cubit de Prueba**:

- Constructor adicional `.test()` con valores por defecto para testing
- Facilita inyectar dependencias mock en pruebas

### 3.3 Capa de Estado (State)

**Ubicación**: `lib/[modulo]/cubit/state.dart` (parte del archivo cubit)

**Responsabilidades**:

- Representar el estado actual de la funcionalidad
- Ser inmutable y equatable para comparaciones

**Patrón de State**:

- Hereda de `Equatable` para igualdad de objetos
- Tiene método `copyWith()` para crear nuevas instancias con cambios
- Todas las propiedades son `final`

### 3.4 Capa de Entidades (Entities)

**Ubicación**: `lib/[modulo]/entities/`

**Responsabilidades**:

- Definir modelos de dominio
- Encapsular lógica de negocio específica de la entidad
- Agrupar comportamientos relacionados

**Patrón de Entidad**:

- Pueden ser Flame Components con comportamientos
- Pueden ser objetos de valor con lógica de negocio
- Pueden tener subestructuras organizadas por comportamiento

### 3.5 Capa de Componentes Reutilizables (Widgets)

**Ubicación**: `lib/[modulo]/widgets/`

**Responsabilidades**:

- Proporcionar componentes visuales reutilizables
- Ser agnósticos a la lógica de negocio
- Ser simples y enfocados

**Patrón de Widget**:

- Widgets de presentación puros
- Pueden aceptar callbacks para interacciones
- No conocen sobre Cubits u otra lógica

---

## 4. Organización de Módulos Especializados

### Módulo de Juego (game/)

**Estructura especial** para lógica del juego Flame:

```
game/
├── dark_game.dart          # Clase principal del juego (FlameGame)
├── game.dart               # Exportaciones públicas
├── components/             # Componentes visuales del juego
├── cubit/                  # Lógica de estado (audio, etc.)
├── entities/               # Entidades del juego
└── view/                   # Vistas que contienen el juego
```

**Patrón FlameGame**:

- Hereda de `FlameGame`
- Inicializa componentes del mundo en `onLoad()`
- Gestiona lógica global del juego
- Se inyecta como dependencia en componentes

**Patrón de Componentes Flame**:

- Heredan de `PositionComponent` o `PositionedEntity`
- Tienen ciclo de vida (`onLoad()`, `update()`, `render()`)
- Pueden tener `behaviors` que encapsulan comportamientos específicos
- Acceso a `game` para obtener referencia al juego

### Módulo de Carga (loading/)

**Propósito**: Gestionar precargas de recursos

**Estructura**:

- `PreloadCubit`: Orquesta la carga de recursos
- `PreloadState`: Expone progreso y estado de carga
- `LoadingPage`: UI que muestra progreso
- Widgets para visualizar progreso

**Patrón**:

- Se inicializa antes de la aplicación principal
- Emite actualizaciones de progreso
- Señala cuando la carga está completa

### Módulo de Localización (l10n/)

**Propósito**: Manejar internacionalización

**Estructura**:

- `arb/`: Archivos de definición de traducciones
- `gen/`: Código generado automáticamente
- `l10n.dart`: Exportaciones públicas

**Patrón**:

- Acceso a traducciones via `context.l10n`
- `AppLocalizations` proporciona métodos para obtener strings
- Generado automáticamente via `flutter gen-l10n`

---

## 5. Sistema de Exportaciones (Barrels)

### Concepto

Cada módulo y subcarpeta tiene un archivo que exporta su contenido público:

```
archivo_de_barril.dart:
export 'submodule1/file1.dart';
export 'submodule2/file2.dart';
export 'entities/entity.dart';
```

### Ventajas

1. **Interface Limpia**: Expone solo lo público del módulo
2. **Refactoring Seguro**: Cambios internos no afectan importadores
3. **Organización Clara**: Identifica fácilmente qué es público
4. **Imports Simples**: `import 'package:app/module/module.dart'`

### Práctica

- Cada carpeta relevante tiene un `archivo_barril.dart`
- El nombre del archivo barril coincide con el de la carpeta
- No exportar internals o detalles de implementación

---

## 6. Estructura de Tests

### Espejo de `lib/`

La carpeta `test/` replica la estructura de `lib/`:

```
test/
├── helpers/                # Utilidades compartidas para tests
├── app/
├── game/
├── loading/
└── title/
```

**Principio**: Cada módulo en `lib/` tiene una carpeta correspondiente en `test/`.

### Carpeta de Helpers

**Ubicación**: `test/helpers/`

**Contenido típico**:

- **pump_app.dart**: Extensiones para `WidgetTester` que facilitan renderizar la app en tests
- **mocks.dart**: Mocks y stubs reutilizables
- **test_game.dart**: Utilidades para testear lógica de Flame
- **helpers.dart**: Funciones auxiliares generales

### Patrón PumpApp

Una extensión `PumpApp` en `WidgetTester` que:

1. Configura todos los Providers necesarios
2. Crea mocks de dependencias
3. Inyecta localizaciones
4. Renderiza el widget en un contexto simulado realista

### Patrón de Mocks

- Se heredan de `MockCubit<State>` o `Mock`
- Se usan con `mocktail` para stubbing
- Se inyectan en tests para aislar unidades

### Tipos de Tests

La plantilla soporta:

- **Unit Tests**: Lógica pura sin widgets (Cubits, funciones)
- **Widget Tests**: Componentes UI en aislamiento
- **Integration Tests**: Flujos completos de la aplicación

---

## 7. Gestión de Dependencias

### Principios

1. **Inyección de Dependencias**: Las dependencias se pasan al constructor
2. **Abstracción**: Dependencias externas se inyectan, no se instancian internamente
3. **Testabilidad**: Todas las dependencias pueden ser reemplazadas por mocks

### Patrón de Inicialización

En `bootstrap.dart` y `main_*.dart`:

- Se crean todas las dependencias necesarias
- Se inyectan en el árbol de widgets vía `BlocProvider`
- La aplicación recibe dependencias por inyección

### Gestión de Recursos

- `Cubit.close()` se sobrescribe para limpiar recursos
- Listeners se limpian automáticamente
- Streams y suscripciones se manejan correctamente

---

## 8. Convenciones de Nombre

### Archivos

- **Archivos de barril**: Nombre igual a la carpeta (ej: `game.dart` en carpeta `game/`)
- **Test files**: Sufijo `_test.dart` (ej: `audio_cubit_test.dart`)
- **Mock files**: Combinan con sufijo o prefijo descriptivo
- **Páginas**: Sufijo `_page.dart` (ej: `loading_page.dart`)

### Clases

- **Cubits**: Sufijo `Cubit` (ej: `AudioCubit`)
- **States**: Sufijo `State` (ej: `AudioState`)
- **Pages**: Sufijo `Page` (ej: `LoadingPage`)
- **Componentes Flame**: Nombre descriptivo (ej: `Unicorn`, `CounterComponent`)
- **Mocks**: Prefijo `Mock` o sufijo `Mock` (ej: `MockPreloadCubit`)

### Variables Privadas

- Prefijo `_` para variables privadas
- Prefijo `_` para métodos privados
- Usados internamente en la clase

---

## 9. Buenas Prácticas

### Principios SOLID

1. **S - Single Responsibility**: Cada clase tiene una única razón para cambiar
2. **O - Open/Closed**: Abierto para extensión, cerrado para modificación
3. **L - Liskov Substitution**: Los subtipos son sustituibles por sus tipos base
4. **I - Interface Segregation**: Interfaces específicas en lugar de generales
5. **D - Dependency Inversion**: Depender de abstracciones, no de implementaciones concretas

### Evitar

- **Lógica en Widgets**: La lógica compleja va en Cubits
- **Dependencias Globales**: Inyectar en lugar de usar singletons
- **Violación del Ciclo de Vida**: Respetar `onLoad()`, `onDispose()`, etc.
- **Estados Mutables**: Los estados deben ser inmutables
- **Imports Circulares**: Evitar dependencias cíclicas

### Ventajas

- **Testabilidad Alta**: Cada unidad se testa en aislamiento
- **Reutilización**: Componentes desacoplados son reutilizables
- **Mantenimiento**: Código claro y organizado
- **Colaboración**: Nuevos desarrolladores entienden la estructura rápidamente

---

## 10. Análisis de Código y Linting

### Configuración

El proyecto utiliza `very_good_analysis` que define:

- Reglas de lint estrictas
- Formato de código consistente
- Documentación API esperada

### Archivos de Configuración

- **analysis_options.yaml**: Define reglas de análisis
- Excluye código generado de ciertos análisis
- Personaliza reglas específicas del proyecto

### Herramientas

- `dart format`: Formatea código automáticamente
- `dart analyze`: Identifica problemas de código
- `dart fix`: Aplica correcciones automáticas

---

## 11. Ciclo de Vida de la Aplicación

### Secuencia de Inicialización

1. **main_[flavor].dart** es el punto de entrada
2. Se configuran flavores y variables de entorno
3. Se llama a `bootstrap()` con la aplicación configurada
4. **bootstrap.dart** inicializa BlocObserver y excepciones globales
5. Se renderiza el widget raíz
6. Se inicia `PreloadCubit` para cargar recursos
7. Se muestra `LoadingPage` mientras se precargan recursos
8. `PreloadCubit` emite estado completo
9. Se navega a `TitlePage`

### Gestión de Ciclo de Vida en Cubits

```
Constructor -> Emits State -> onLoad() -> emit() -> close()
```

### Gestión de Ciclo de Vida en Componentes Flame

```
Instanciación -> onLoad() -> update(dt) -> onRemove()
```

---

## 12. Patrones de Comunicación

### Entre Cubits y Widgets

- Widgets consumen estado vía `BlocBuilder`
- Widgets escuchan cambios vía `BlocListener`
- Widgets invocan métodos del Cubit en respuesta a eventos

### Entre Componentes Flame

- Acceso a otros componentes vía `parent` o referencias directas
- Comunicación con el juego vía `game` (GameReference)
- Comportamientos (`behaviors`) encapsulan interacciones

### Entre Módulos

- Módulos se comunican vía:
  - Navegación (pushReplacement, push)
  - Cubits globales inyectados
  - Callbacks pasados como parámetros

---

## 13. Características Especiales de Flame

### Componentes vs Widgets

- **Componentes Flame**: Dibujados en canvas por el motor del juego
- **Widgets Flutter**: UI tradicional del framework

### Behaviors

Encapsulan comportamientos específicos de componentes:

- Se asignan al crear el componente
- Manejan actualizaciones y eventos
- Facilitan composición sobre herencia

### GameReference

Proporciona acceso al juego desde componentes:

- Mixin `HasGameReference` inyecta referencia al juego
- Permite acceso a propiedades globales del juego
- Facilita comunicación entre componentes

### Animaciones

- `SpriteAnimation` define secuencias de frames
- `SpriteAnimationComponent` renderiza y controla animaciones
- `animationTicker` controla reproducción

---

## 14. Recursos y Assets

### Organización

```
assets/
├── audio/          # Archivos de audio
├── images/         # Archivos de imágenes
└── licenses/       # Archivos de licencias
```

### Generación de Código

El archivo `assets.gen.dart` se genera automáticamente y proporciona:

- Acceso type-safe a recursos
- Rutas correctas sin hardcoding
- Autocompletado en IDE

### Localización

- Archivos `.arb` definen strings traducidos
- `gen_l10n_inputs_and_outputs.json` rastrean generación
- Acceso vía `context.l10n` después de `AppLocalizations.delegate`

---

## 15. Flujo de Trabajo del Desarrollador

### Agregar Nueva Funcionalidad

1. Crear carpeta del módulo en `lib/`
2. Crear estructura: `view/`, `cubit/`, `entities/` (según necesidad)
3. Crear archivo barril
4. Implementar Cubit si hay lógica de estado
5. Implementar Widget/Page
6. Crear tests espejo en `test/`
7. Inyectar en `bootstrap.dart` o punto de entrada

### Agregar Nuevo Test

1. Crear estructura espejo en `test/`
2. Importar helpers de `test/helpers/`
3. Usar `blocTest` para Cubits
4. Usar `pumpApp` para Widgets
5. Usar mocks de `test/helpers/mocks.dart`

### Refactoring Seguro

1. Los archivos barril aíslan cambios internos
2. Los tests validan comportamiento no ha cambiado
3. El linting detecta problemas antes del runtime

---

## 16. Ventajas de la Plantilla

- **Escalabilidad**: Fácil agregar módulos sin afectar existentes
- **Testabilidad**: 100% del código puede ser testeado
- **Mantenibilidad**: Código organizado y convenciones claras
- **Performance**: Flame optimizado para juegos
- **Community**: Patrones similares a otros proyectos Very Good
- **CI/CD Ready**: Integración con pipelines de automatización

---

## 17. Patrones de Inyección de Dependencias

### Niveles de Inyección

**Nivel 1: Raíz de la Aplicación (main_*.dart)**

El punto de entrada es donde se definen las dependencias globales más básicas:

- Configuración de variables de entorno
- Llamada al bootstrap con la aplicación raíz
- Punto único donde la aplicación se inicia

**Nivel 2: Bootstrap**

En `bootstrap.dart` se configura:

- Observadores globales (BlocObserver)
- Manejo global de errores
- Licencias y recursos
- Configuración cross-flavor

**Nivel 3: Widget Raíz (App)**

El widget `App` es donde:

- Se crean Cubits principales via `BlocProvider`
- Se inicializan servicios y recursos
- Se inyectan en el árbol de widgets
- Se inicia lógica de carga

**Nivel 4: Subárbol de Widgets**

Los widgets descendientes consumen lo inyectado:

- Via `context.read<T>()` para acceso directo
- Via `BlocBuilder<T>` para UI reactiva
- Via `BlocListener<T>` para efectos secundarios

### Beneficios

- **Testing**: Fácil reemplazar dependencias
- **Configuración**: Diferentes setupeos por entorno
- **Desacoplamiento**: Módulos independientes
- **Flexibilidad**: Cambiar implementaciones sin tocar código

---

## 18. Estructura del Widget Raíz

### Responsabilidades del Widget App

El widget raíz (generalmente llamado `App`) cumple:

1. **Creación de Cubits Globales**: Cubits que se usan en toda la aplicación
2. **Múltiples Providers**: Inyecta varios Cubits vía `MultiBlocProvider`
3. **Inicialización de Recursos**: Llama métodos para precargar datos
4. **Configuración del Tema**: Define `MaterialApp` con tema global
5. **Configuración de Localizaciones**: Inyecta delegados de traducciones
6. **Rutas Iniciales**: Define página de inicio

### Separación App vs AppView

- **App**: Maneja providers e inyección
- **AppView**: Maneja configuración visual y Material

Esto permite testear cada parte por separado.

---

## 19. Gestión de Temas y Configuración Global

### Temas de Material Design

El `MaterialApp` centraliza:

- **ColorScheme**: Paleta de colores principal
- **TextTheme**: Estilos de texto predefinidos
- **AppBarTheme**: Estilo de barras de aplicación
- **ScaffoldBackgroundColor**: Color de fondo

### Configuración por Flavor

Diferentes temas pueden aplicarse según:

- `main_development.dart`: Tema con colores vibrantes para debug
- `main_staging.dart`: Tema similar a producción
- `main_production.dart`: Tema final optimizado

---

## 20. Generación de Código Automático

### Assets (assets.gen.dart)

Se genera automáticamente cuando:

- Se agregan archivos a `assets/`
- Se ejecuta `flutter pub get`
- Se compila el proyecto

**Proporciona**:

- Acceso type-safe a recursos
- Previene typos en rutas
- Autocompletado en IDE

### Localización (l10n/gen/)

Se genera automáticamente cuando:

- Se modifica `l10n.yaml`
- Se actualizan archivos `.arb`
- Se ejecuta `flutter gen-l10n`

**Proporciona**:

- Clases `AppLocalizations` con métodos para cada string
- Acceso type-safe a traducciones
- Soporte multi-idioma

---

## 21. Navegación en Very Good Game Template

### Patrones de Navegación

**Tipos de navegación**:

- **push()**: Agrega pantalla a stack (permite retroceso)
- **pushReplacement()**: Reemplaza pantalla actual
- **pop()**: Vuelve a pantalla anterior
- **pushNamedRoute()**: Navegación nombrada

### Integración con Cubits

Cubits pueden:

1. Emitir estados que disparan navegación via `BlocListener`
2. Recibir datos post-navegación
3. Manejar lógica de decisión de rutas

---

## 22. Rendimiento y Optimizaciones

### Evitar Rebuilds Innecesarios

**Técnicas**:

- `BlocBuilder` con `buildWhen` para filtrar rebuilds
- `const` en constructores cuando es posible

### Performance en Flame

- Actualizar solo cuando es necesario en `update()`
- Usar `onRemove()` para limpiar recursos
- Evitar asignaciones innecesarias en hot paths

---

## 23. Manejo de Errores y Excepciones

### Niveles de Manejo de Errores

**Nivel 1: Global (bootstrap.dart)**

- `FlutterError.onError`: Errores de framework
- `PlatformDispatcher.onError`: Errores asincrónicos

**Nivel 2: Cubit**

- Try-catch en métodos
- Estados de error
- Logging de errores

**Nivel 3: Widget**

- `BlocListener` para reaccionar a errores
- Mostrar snackbars o diálogos

---

## 24. Integración Continua y Deployment

### Pipeline CI/CD

La estructura permite:

- **Análisis estático**: `dart analyze`
- **Formato**: `dart format`
- **Tests**: `dart test` o `flutter test`
- **Build**: `flutter build apk/ipa/web`

### Automatización

- Tests ejecutados en cada commit
- Linting fuerza estándares
- Build automático de releases

---

## 25. Escalabilidad del Proyecto

### Crecimiento Modular

A medida que el proyecto crece:

1. **Agregar nuevos módulos** sin modificar existentes
2. **Dividir módulos grandes** en submódulos
3. **Extractar lógica compartida** a módulos comunes

### Estructura para Múltiples Juegos

La plantilla escala a:

- Múltiples juegos en una app
- Componentes compartidos entre juegos
- Configuración centralizada

---

## 26. Mejores Prácticas de Colaboración

### Para Equipos

**Comunicación vía Código**:

- Nombres claros y convenciones
- Estructura auto-documentada
- Tests como especificaciones

**Onboarding**:

- Nueva estructura es obvia para desarrolladores
- Convenciones reducen decisiones
- Tests sirven como documentación viva

---

## 27. Patrón de Behaviors en Flame (Profundizado)

### Concepto de Behaviors

Los behaviors son mixins que añaden funcionalidad específica a componentes Flame sin usar herencia:

**Ventajas**:

- **Composición sobre Herencia**: Combinar múltiples behaviors en un componente
- **Reutilización**: Mismo behavior en diferentes tipos de componentes
- **Separación de Responsabilidades**: Cada behavior maneja una preocupación específica
- **Testing**: Testear behaviors independientemente

### Anatomía de un Behavior

Un behavior típico:

```text
Behavior
├── Extiende: Behavior<Parent>
├── Implementa lógica específica
├── Accede al parent (componente que lo contiene)
├── Puede tener su propio estado
└── Se ejecuta en el ciclo de vida del componente
```

### Tipos Comunes de Behaviors

**Input Behaviors**:

- Manejan interacción del usuario (tap, drag, hover)
- Se añaden a componentes que requieren interactividad
- Procesan eventos de entrada

**Movement Behaviors**:

- Controlan movimiento automático
- Patrullas, seguimiento, trayectorias
- Actualizan posición en `update()`

**Animation Behaviors**:

- Controlan ciclos de animación
- Transiciones de estado visual
- Sincronización con lógica de juego

**Collision Behaviors**:

- Manejan detección y respuesta a colisiones
- Se integran con sistema de colisiones de Flame

### Comunicación entre Behaviors

- Acceso al componente parent
- Acceso a otros behaviors del mismo parent
- Comunicación via propiedades compartidas del parent
- No deben acoplarse directamente entre sí

### Cuándo Crear un Behavior

**SÍ crear behavior cuando**:

- La funcionalidad se reutiliza en múltiples componentes
- La lógica es ortogonal a la responsabilidad principal del componente
- Necesitas testear la funcionalidad aisladamente

**NO crear behavior cuando**:

- La lógica es específica a un solo componente
- La funcionalidad es muy simple (una línea)
- Requiere estado complejo que pertenece al componente

---

## 28. Testing de Componentes Flame

### Herramientas de Testing

**flame_test package**:

- Utilidades específicas para testear componentes Flame
- `TestGame`: Juego simplificado para tests
- `flameTester`: Helper para tests de componentes

### Estrategias de Testing

**Unit Tests de Componentes**:

```text
setUp() {
  // Crear TestGame
  // Instanciar componente
  // Configurar estado inicial
}

test('comportamiento específico') {
  // Act: Llamar método o simular evento
  // Assert: Verificar estado del componente
}
```

**Testing de Behaviors**:

- Testear behavior independientemente del componente
- Crear componente mock simple
- Verificar que el behavior modifica correctamente el parent

**Testing de Animaciones**:

- Verificar frames de animación
- Testear transiciones de estado
- Validar sincronización con lógica

### Patrón TestGame

Crear juegos de prueba simplificados:

```text
TestGame
├── Sin assets complejos
├── Configuración mínima
├── Facilita inyección de componentes
└── Permite verificar estado del juego
```

### Mocking en Tests de Flame

- Mocktail para dependencias externas
- Componentes simplificados para tests
- Stubs de assets y recursos

---

## 29. Gestión de Audio y Sonido

### Arquitectura de Audio

**AudioCubit**: Centraliza control de audio

**Responsabilidades**:

- Controlar volumen global
- Mute/Unmute
- Gestionar lifecycle de audio players
- Exponer estado de audio a la UI

### Tipos de Audio

**Background Music (BGM)**:

- Loop continuo
- Controlado por `Bgm` de flame_audio
- Un solo track a la vez típicamente

**Sound Effects**:

- Eventos puntuales
- Múltiples efectos simultáneos
- Controlados por `AudioPlayer` de audioplayers

### Patrón de Implementación

**Estructura típica**:

```text
AudioCubit
├── AudioPlayer effectPlayer (efectos)
├── Bgm backgroundMusic (música de fondo)
├── AudioState (volumen actual)
├── toggleVolume() (alternar silencio)
└── close() (limpiar recursos)
```

**AudioState**:

- Inmutable
- Contiene volumen actual
- Usa copyWith() para cambios

### Integración con UI

- `BlocBuilder` para mostrar estado de audio (icono mute/unmute)
- `BlocListener` para cambios de audio
- Widgets de control de volumen

### Preloading de Audio

- Precargar en `PreloadCubit`
- Cache de audio para performance
- Liberar recursos en cleanup

---

## 30. Patrones de Estados Complejos

### Estados Simples vs Complejos

**Estado Simple**:

- Pocos campos (1-3)
- Lógica directa
- Un solo propósito

**Estado Complejo**:

- Múltiples campos (4+)
- Estados de carga, éxito, error
- Necesita discriminación de casos

### Patrón de Estado con Status

```text
State {
  final Status status;          // loading, success, error
  final Data? data;             // Datos cuando success
  final String? errorMessage;   // Mensaje cuando error
  final double progress;        // Progreso cuando loading
}
```

**Ventajas**:

- Claridad sobre estado actual
- Fácil discriminación en UI
- Previene estados inválidos

### Estados Sealed (Conceptual)

Aunque Dart no tiene sealed classes nativas, el concepto:

```text
State Base
├── InitialState
├── LoadingState(progress)
├── SuccessState(data)
└── ErrorState(message)
```

**Implementación**:

- Clases separadas que extienden base
- Pattern matching en UI via `is` o visitors
- Tipo seguro

### Copyables y Equatable

**copyWith()**:

- Permite crear nuevas instancias con cambios parciales
- Mantiene inmutabilidad
- Esencial para estados complejos

**Equatable**:

- Compara estados por valor, no referencia
- Previene rebuilds innecesarios
- Esencial para BLoC

---

## 31. Decisiones de Arquitectura

### Cuándo Usar Cubit vs Bloc

**Usar Cubit cuando**:

- Lógica de estado simple
- Métodos directos sin eventos complejos
- No necesitas replay de eventos
- Mayoría de casos en la plantilla

**Usar Bloc cuando**:

- Necesitas replay/undo de eventos
- Eventos complejos con múltiples tipos
- Logging detallado de eventos
- Casos muy específicos

### Cuándo Crear Nuevo Módulo

**Crear módulo cuando**:

- Nueva pantalla o flujo independiente
- Funcionalidad cohesiva con múltiples archivos
- Necesita su propio estado (Cubit)
- Se puede testear independientemente

**NO crear módulo cuando**:

- Es un widget simple reutilizable (va en widgets/)
- Es una utilidad compartida (crear módulo common/)
- Es configuración global (va en app/)

### Entity vs Component vs Widget

**Entity (Flame)**:

- Lógica de juego
- Dibujado en canvas
- Ciclo de vida de Flame
- Interacción con game loop

**Component (Flutter)**:

- Widget reutilizable
- Dibujado con framework Flutter
- No depende de Flame
- Para UI tradicional

**Widget (Flutter)**:

- Presentación simple
- Stateless típicamente
- Sin lógica de negocio

### Cuándo Usar Behaviors

**Usar Behavior cuando**:

- Funcionalidad se repite en varios componentes
- Lógica es ortogonal (tap, movement, etc.)
- Quieres testear separadamente
- Composición mejora legibilidad

**Usar métodos del componente cuando**:

- Lógica es específica del componente
- No se reutiliza
- Es parte esencial del componente

---

## 32. Antipatrones Comunes a Evitar

### 1. God Objects

**Problema**: Clases que hacen demasiado

**En Cubits**:

- Cubit que maneja múltiples responsabilidades
- Métodos que no relacionan al dominio del Cubit

**Solución**:

- Separar en múltiples Cubits
- Cada Cubit una responsabilidad

### 2. Importar Internals

**Problema**: Importar archivos internos de otros módulos

```text
❌ import 'package:app/game/cubit/audio/audio_cubit.dart';
✅ import 'package:app/game/game.dart';
```

**Solución**:

- Siempre importar vía barrels
- Mantener APIs públicas limpias

### 3. Lógica en Widgets

**Problema**: Business logic en build() o callbacks de widgets

**Solución**:

- Mover lógica a Cubits
- Widgets solo presentan y delegan

### 4. State Mutable

**Problema**: Modificar propiedades del estado directamente

```text
❌ state.counter++;
✅ emit(state.copyWith(counter: state.counter + 1));
```

**Solución**:

- Estados inmutables siempre
- Emitir nuevas instancias

### 5. Singletons y Globals

**Problema**: Usar singletons para dependencias

**Solución**:

- Inyectar vía constructor
- Pasar via BlocProvider
- Mantener testabilidad

### 6. Tests que Dependen de Orden

**Problema**: Tests que fallan si corren en diferente orden

**Solución**:

- Cada test independiente
- setUp() para inicialización
- tearDown() para limpieza

### 7. Assets Hardcoded

**Problema**: Rutas de assets como strings

```text
❌ 'assets/images/player.png'
✅ Assets.images.player
```

**Solución**:

- Usar assets.gen.dart siempre
- Type-safe access

### 8. Mixing Concerns

**Problema**: Mezclar lógica de UI con lógica de juego

**Solución**:

- Flame components para juego
- Flutter widgets para UI
- Comunicación vía Cubits

---

## 33. Migración y Evolución del Código

### Agregar Nueva Dependencia

**Proceso**:

1. Agregar a `pubspec.yaml`
2. Ejecutar `flutter pub get`
3. Importar donde se necesite
4. Documentar en README si es crítica

### Refactorizar Módulo Existente

**Estrategia segura**:

1. Tests existentes pasan
2. Crear nueva estructura en paralelo
3. Migrar código gradualmente
4. Actualizar tests
5. Eliminar código viejo
6. Todos los tests pasan

### Dividir Módulo Grande

**Cuando un módulo crece mucho**:

```text
game/
├── game.dart (mantener como barrel principal)
├── entities/
│   ├── player/ (nuevo submódulo)
│   ├── enemies/ (nuevo submódulo)
│   └── items/ (nuevo submódulo)
└── systems/
    ├── collision/ (nuevo submódulo)
    └── scoring/ (nuevo submódulo)
```

**Proceso**:

- Crear submódulos con su propio barrel
- Mover archivos a submódulos
- Actualizar barrel principal
- Actualizar imports (via barrel)
- Tests siguen pasando

### Actualizar Dependencias

**Proceso seguro**:

1. Revisar CHANGELOG de dependencias
2. Actualizar en entorno de desarrollo
3. Correr tests completos
4. Verificar breaking changes
5. Actualizar código si necesario
6. Commit y push

### Deprecar Funcionalidad

**Patrón**:

1. Marcar como `@deprecated`
2. Documentar alternativa
3. Mantener funcionalidad temporalmente
4. Remover en versión futura
5. Actualizar documentación

---

## 34. Debugging y Troubleshooting

### Debugging de Cubits

**BlocObserver**:

- Logs automáticos de cambios de estado
- Ver cada `emit()` en consola
- Identificar estados inesperados

**Técnicas**:

- Breakpoints en métodos de Cubit
- Inspeccionar estado antes/después de emit
- Verificar que close() se llama

### Debugging de Flame Components

**Herramientas**:

- `debugMode = true` en FlameGame
- Visualizar hitboxes
- Ver árbol de componentes
- Logs en update() (con cuidado en performance)

**Técnicas**:

- Verificar que onLoad() completa
- Validar que update() se llama
- Inspeccionar posición y tamaño
- Revisar parent hierarchy

### Problemas Comunes

**Widget no reconstruye**:

- Verificar que Equatable está implementado
- Verificar que emit() se llama
- Verificar que BlocBuilder escucha el Cubit correcto

**Componente Flame no aparece**:

- Verificar que se agregó con add()
- Verificar posición y tamaño
- Verificar que onLoad() completa
- Verificar cámara y viewport

**Tests fallan aleatoriamente**:

- Verificar operaciones asincrónicas
- Usar `await tester.pump()` apropiadamente
- Verificar mocks están correctamente stubbed
- Asegurar independencia entre tests

### Logs y Telemetría

**Development**:

- Logs verbose para debugging
- BlocObserver con prints detallados

**Production**:

- Logs mínimos
- Telemetría para errores críticos
- No exponer información sensible

---

## 35. Recursos y Aprendizaje Continuo

### Documentación Oficial

**Flutter**:

- flutter.dev
- API documentation
- Widget catalog

**Flame**:

- docs.flame-engine.org
- Examples repository
- Community packages

**BLoC/Cubit**:

- bloclibrary.dev
- Best practices guide
- Architecture recommendations

### Very Good Ventures

**Recursos**:

- Very Good CLI
- Very Good Workflows (CI/CD)
- Blog con mejores prácticas
- Open source templates

### Patrones de Código

**Aprender de**:

- Proyectos open source que usan la plantilla
- Very Good Engineering blog
- Conferencias y charlas
- Code reviews de equipo

### Comunidad

**Dónde preguntar**:

- GitHub discussions del template
- Discord de Flame
- Stack Overflow (tags: flutter, flame, bloc)
- Reddit r/FlutterDev

### Mantenerse Actualizado

- Seguir changelog de dependencias
- Revisar updates de la plantilla
- Participar en comunidad
- Experimentar con nuevas features

---

## Resumen Extendido

Very Good Game Template proporciona una arquitectura robusta que combina:

- **Arquitectura Limpia**: Separación clara de responsabilidades
- **BLoC Pattern**: Gestión de estado escalable
- **Flame Engine**: Optimizado para juegos
- **Testing First**: Diseño que facilita testing exhaustivo
- **Convenciones Claras**: Código autodocumentado vía estructura y nombres
- **Inyección de Dependencias**: Flexibilidad y testabilidad
- **Modularidad**: Crecimiento sin límites
- **Colaboración**: Código que habla por sí solo

Seguir estos patrones asegura que el código sea:

- **Fácil de mantener**: Estructura clara y consistente
- **Fácil de testear**: Inyección y aislamiento de dependencias
- **Fácil de escalar**: Agregar features sin complejidad exponencial
- **Fácil de colaborar**: Convenciones que todos entienden
- **Fácil de debuggear**: Errores claros y trazabilidad
- **Fácil de refactorizar**: Tests dan confianza en cambios

Este documento sirve como referencia rápida para nuevos desarrolladores y como guía para mantener consistencia en el proyecto.

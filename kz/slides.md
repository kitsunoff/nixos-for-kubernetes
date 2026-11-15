---
theme: default
title: NixOS как KubernetesOS
info: |
  Идеальная ОС для bare-metal Kubernetes — и не только.
  Доклад для devops/sre.
layout: cover
colorSchema: dark
highlighter: shiki
lineNumbers: true
fonts:
  sans: Martian Mono
  mono: JetBrains Mono
  provider: none
drawings:
  persist: false
transition: fade
mdc: true
eyebrow: "03 / ОС: от классики к декларативности"
speaker: Максим Белый
role: Platform Engineer · Aenix
---

# NixOS как KubernetesOS

Идеальная ОС для bare-metal Kubernetes — и&nbsp;не&nbsp;только

---
layout: two-cols
---

# Кто я

**Максим Белый** · aka Макс Китсун

- Platform Engineer в **Aenix**, до этого в **X5**
- В прошлой жизни — C#-разработчик, ушёл в DevOps и не вернулся
- **NixOS-шиз** на проде и дома: эксплуатирую, контрибьючу, страдаю
- Организую **re:Homelab Meetup** — собираю девопсов вокруг self-hosted'а
- Фотограф — хобби, которое греет

<div class="pt-8 text-sm opacity-75">
  github.com/kitsunoff · maxim.kitsun@aenix.io
</div>

::right::

<div class="grid grid-cols-2 gap-2 pl-6 h-full content-center">
  <img src="/about/01.jpg" class="rounded-lg w-full aspect-square object-cover" />
  <img src="/about/02.jpg" class="rounded-lg w-full aspect-square object-cover" />
  <img src="/about/03.jpg" class="rounded-lg col-span-2 w-full aspect-[16/9] object-cover" />
</div>

---

# Что я ищу

Идеальную ОС для своего **bare-metal** — homelab и прод

- На ней крутится **Kubernetes**
- И **не только**: VM, Incus, self-hosted-сервисы рядом
- Гибкая по железу, без жертв в виде отладочных инструментов

→ Сегодня — **как я к этому пришёл** и почему остановился на **NixOS**.
Не обзор — путь и работающий стек.

---

# Путь к декларативности

<div class="text-sm opacity-75 -mt-2">Как настраивали машины — одна ось: от «руками» до «описываю состояние»</div>

<div class="pt-24 pb-14">
  <div class="axis">
    <div class="axpt up" style="left:7%"><span class="dot"></span><span class="lbl"><span class="nm">Руками</span><span class="sub">SSH · bash, по памяти — снежинки</span></span></div>
    <div class="axpt down" style="left:31%"><span class="dot"></span><span class="lbl"><span class="nm">Ansible · Puppet</span><span class="sub">config management — шаги, дрифт</span></span></div>
    <div class="axpt up" style="left:53%"><span class="dot"></span><span class="lbl"><span class="nm">cloud-init</span><span class="sub">bootstrap из образа, дальше мутабельно</span></span></div>
    <div class="axpt down" style="left:75%"><span class="dot"></span><span class="lbl"><span class="nm">Immutable-дистрибутивы</span><span class="sub">Flatcar · CoreOS — A/B-образ, read-only</span></span></div>
    <div class="axpt up win" style="left:93%"><span class="dot"></span><span class="lbl"><span class="nm">Декларативно</span><span class="sub">состояние + lock</span></span></div>
  </div>
  <div class="axends"><span>← полностью мутабельно</span><span>декларативно · immutable →</span></div>
</div>

<div class="text-sm opacity-80 max-w-3xl">
Каждый шаг чинил предыдущую боль, но воспроизводимость выходит только когда
описываешь, <b>что должно быть</b>, а не <b>как туда прийти</b> — и это лежит под git.
</div>

→ Отсюда и весь поиск: **декларативная нода как код**. Дальше — по чему я мерил кандидатов.

---

# Идеальная ОС: чек-лист

<div class="text-sm opacity-75 -mt-2">Чего я хочу от ноды — до того, как смотреть на конкретные дистрибутивы</div>

<div class="grid grid-cols-2 gap-x-10 gap-y-4 pt-5">
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Декларативная воспроизводимая нода</div>
      <div class="text-sm opacity-70">config = код + lockfile</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Atomic upgrades + мгновенный rollback</div>
      <div class="text-sm opacity-70">обновился и откатился одним действием</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Kubernetes из коробки</div>
      <div class="text-sm opacity-70">без kubeadm-плясок руками</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Полный debug на живой ноде</div>
      <div class="text-sm opacity-70">SSH, journalctl, strace</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Любые kernel modules / драйверы / GPU</div>
      <div class="text-sm opacity-70">без version-lock к релизу ОС</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Не только k8s</div>
      <div class="text-sm opacity-70">VM, Incus, сервисы — той же моделью</div>
    </div>
  </div>
  <div class="flex gap-3 items-start">
    <span class="text-[#18C0B1] text-xl leading-none">✓</span>
    <div>
      <div class="font-bold">Открытость / governance</div>
      <div class="text-sm opacity-70">не заперто на одном вендоре</div>
    </div>
  </div>
</div>

→ Самый близкий к этому списку сегодня — **Talos**. С него и начну.

---

# Talos как идеал

Talos поднял планку — многое он делает **правильно**:

- **Декларативная нода как код** — вся нода = один `machineconfig.yaml`
- **Atomic A/B upgrades + rollback** из коробки
- **Kubernetes встроен** — `talosctl bootstrap`, без kubeadm-плясок
- **Минимальная attack surface** — read-only squashfs, нет лишнего
- Хорошая интеграция с k8s-экосистемой, Omni для bare-metal

→ Без Talos этого доклада бы не было. Вопрос — где он **упёрся для меня**.

---

# Где Talos упёрся

<div class="text-sm opacity-75 -mt-2">Не баг, а сознательная цена opinionated-дизайна</div>

<div class="tbl grid grid-cols-[1fr_1.5fr] gap-[3px] pt-4">
  <div class="th">Хотел</div>
  <div class="th">В Talos</div>
  <div class="rh">Зайти на живую ноду</div>
  <div><span class="no">✗</span> нет SSH, нет shell — только gRPC API</div>
  <div class="rh">Свежие GPU-драйверы</div>
  <div>привязаны к версии Talos, апдейт вместе с ОС</div>
  <div class="rh">Любой kernel module</div>
  <div>только System Extensions, пересборка под ядро</div>
  <div class="rh">VM / сервисы рядом с k8s</div>
  <div><span class="no">✗</span> k8s-only по дизайну — host-нагрузок нет</div>
  <div class="rh">Апелляция к governance</div>
  <div><span class="no">✗</span> не в CNCF — продукт одного вендора (Sidero)</div>
</div>

<div class="text-xs opacity-60 pt-2">
Источники: docs.siderolabs.com (FAQ, nvidia-gpu) · cncf.io/projects
</div>

→ Talos великолепен в своей нише. Просто его ниша — **не вся моя задача**.

---

# Вывод по Talos

> Всё это — **по умолчанию свойство закрытого продукта одного вендора**.<br/>
> Не скандал, а осознанный дизайн.

- Если твой use case в их vision **не вписан** — апеллировать некуда
- Это нормально как **выбор**, но это должен быть **осознанный** выбор

→ Мне это **не подошло**. Я стал искать другой инструмент.

<div class="text-xs opacity-60 pt-4">
Деталь для любопытных (одной строкой): фичу «debug на ноде» (issue #8720)
закрывали ~21 месяц — спор о философии внутри одной команды. Подробности — на гитхабе.
</div>

---

# Конфигурируемый vs обычный

<div class="text-sm opacity-75 -mt-2">Куда сел Talos и где вообще живут кандидаты</div>

<div class="grid grid-cols-[1.05fr_0.95fr] gap-8 pt-2 items-center">
  <div>
    <div class="qwrap">
      <div class="qyaxis">Гибкость / открытость →</div>
      <div class="qgrid">
        <div class="ax-v"></div>
        <div class="ax-h"></div>
        <div class="qpt" style="left:20%;top:14%"><span class="dot"></span><span class="nm">Ubuntu/Debian</span></div>
        <div class="qpt" style="left:31%;top:27%"><span class="dot"></span><span class="nm">RHEL/Rocky</span></div>
        <div class="qpt l" style="left:71%;top:43%"><span class="dot"></span><span class="nm">Fedora CoreOS</span></div>
        <div class="qpt l" style="left:70%;top:55%"><span class="dot"></span><span class="nm">Flatcar</span></div>
        <div class="qpt l" style="left:74%;top:31%"><span class="dot"></span><span class="nm">MicroOS</span></div>
        <div class="qpt l" style="left:77%;top:66%"><span class="dot"></span><span class="nm">Kairos</span></div>
        <div class="qpt l" style="left:80%;top:78%"><span class="dot"></span><span class="nm">Talos</span></div>
        <div class="qpt l" style="left:80%;top:90%"><span class="dot"></span><span class="nm">Bottlerocket</span></div>
        <div class="qpt l win" style="left:78%;top:10%"><span class="dot"></span><span class="nm">NixOS-стек</span></div>
      </div>
    </div>
    <div class="qxaxis pl-5">
      <span>Императивный / мутабельный</span>
      <span>Декларативный / atomic →</span>
    </div>
  </div>
  <div class="text-sm">
    <div class="text-[#18C0B1] font-bold pb-1">Две оси</div>
    <div class="opacity-85 pb-4 leading-snug"><b>X →</b> императивный → декларативный / atomic<br/><b>Y ↑</b> закрытый / opinionated → гибкий / открытый</div>
    <div class="flex flex-col gap-3 leading-snug">
      <div><b>Лево-верх</b> — классика (Ubuntu / RHEL): гибкая, но&nbsp;мутабельная</div>
      <div><b>Центр</b> — immutable-OS (Flatcar / FCOS / MicroOS): atomic, средняя гибкость</div>
      <div><b>Низ-право</b> — Talos / Bottlerocket: atomic, но k8s-only и закрыто</div>
      <div class="rounded-lg px-3 py-2 bg-[#18C0B1]/10 border border-[#18C0B1]/40"><b>Право-верх</b> — <span class="text-[#18C0B1] font-bold">только NixOS-стек</span>: декларативный И гибкий</div>
    </div>
    <div class="text-xs opacity-60 pt-4">k3OS† (2023), RancherOS† (2021) — мертвы: урок «k8s-only у одного вендора».</div>
  </div>
</div>

---

# NixOS: минимальный flake

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.node-04 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{
        services.k3s.enable = true;
        services.k3s.role = "agent";
        hardware.nvidia.modesetting.enable = true;
        boot.kernelModules = [ "nvidia" ];
      }];
    };
  };
}
```

После `nixos-rebuild switch --flake .#node-04` — это **работающая нода**.
Один файл, под git, с `flake.lock` для воспроизводимости.

---
layout: section
number: "01"
---

# Стек
## Два интерфейса над одной конфигурацией: CLI как talosctl · и&nbsp;k8s-ресурсы

---
layout: center
---

# Способ 1: сетапить клишкой

<div class="text-lg opacity-85 pt-3">Как <code>talosctl</code> — один CLI, весь кластер в одном файле</div>
<div class="text-2xl font-bold text-[#18C0B1] pt-5"><code>nixclusterctl</code></div>

---

# Декларативность: весь кластер в&nbsp;одном файле

```nix
nixcluster.kz-demo = { clusterModules, self, ... }: {
  imports = with clusterModules;
    [ disko k3s incus sops keepalived ];
  k3s.enable = true;
  sops.enable = true;
  incus.enable = true;
  incus.cluster.enable = true;
  keepalived.enable = true;
  keepalived.instances.k3s-api.vip = "192.168.5.200";
  defaultNixosConfiguration = self.nixosConfigurations.base;

  members.kz-node-1 = {
    install.ip = "192.168.5.3";
    install.disk = "/dev/vda";
    k3s.role = "server";
    # nixos-опции напрямую — patches к base config:
    networking.hostName = "kz-node-1";
  };
};
```

→ Каждый модуль приносит и NixOS-конфиги нодам, и CLI-команды в `nixclusterctl`, и шаги `converge`.

---

# Клишкой — как talosctl

<div class="text-sm opacity-75 -mt-2">Одна команда, один поток: секреты → раскат → join → kubeconfig</div>

```bash
nixclusterctl kz-demo converge --dry-run      # план, ничего не трогает
nixclusterctl kz-demo converge                # весь кластер за один проход
nixclusterctl kz-demo apply kz-node-1         # раскатить одну ноду
nixclusterctl kz-demo k3s kubeconfig fetch    # забрать kubeconfig
```

<div class="grid grid-cols-2 gap-8 pt-2 items-start">
<div class="text-sm">
  <div class="text-[#18C0B1] font-bold pb-1">Знакомо по talosctl</div>
  <div class="tbl grid grid-cols-2 gap-[3px] text-[0.8rem]">
    <div class="th">talosctl</div>
    <div class="th">nixclusterctl</div>
    <div class="rh">gen secrets</div>
    <div class="win">sops gen</div>
    <div class="rh">apply-config</div>
    <div class="win">apply &lt;node&gt;</div>
    <div class="rh">bootstrap</div>
    <div class="win">converge</div>
    <div class="rh">kubeconfig</div>
    <div class="win">k3s kubeconfig fetch</div>
  </div>
</div>
<div class="text-sm">
  <div class="text-[#18C0B1] font-bold pb-1">Модули расширяют клишку</div>
  <div class="opacity-85 leading-snug pb-1">Каждый включённый модуль добавляет свои подкоманды:</div>
  <div class="flex flex-col gap-1 text-[0.82rem]">
    <div><code>nixclusterctl kz-demo incus list</code></div>
    <div><code>nixclusterctl kz-demo k3s nodes</code></div>
    <div><code>nixclusterctl kz-demo keepalived status</code></div>
  </div>
</div>
</div>

<div class="text-xs opacity-60 pt-3">полная форма — <code>nix run .#cluster-kz-demo -- converge</code></div>

---

# Bootstrap новой ноды

<div class="text-sm opacity-75 -mt-2">nixos-anywhere по SSH: разметил диск, поставил систему, заджойнил</div>

<div class="flow pt-10">
  <div class="flow-node">Живой Linux<div class="sub">rescue / live-USB, есть SSH</div></div>
  <div class="flow-arrow"><span class="lbl">добавил в members</span><span class="line">→</span></div>
  <div class="flow-node">nixclusterctl<div class="sub">install &lt;member&gt;</div></div>
  <div class="flow-arrow"><span class="lbl">SSH</span><span class="line">→</span></div>
  <div class="flow-node">Disko +<div class="sub">nixos-anywhere</div></div>
  <div class="flow-arrow"><span class="lbl">k3s join</span><span class="line">→</span></div>
  <div class="flow-node accent">Node Ready<div class="sub">Machine CRD</div></div>
</div>

→ Никакого netboot-хозяйства: нужен только SSH до живого Linux на машине.

---

# Демо: план converge

<div class="text-sm opacity-75 -mt-2">Порядок шагов — просто значение в Nix: модули сами строят DAG</div>

<div class="out-wrapline">

```text {*}{lines:false}
$ nix eval .#clusterConfigurations.kz-demo.convergeOrder
[ "sops.gen" "member-kz-node-1" "member-kz-node-2" "member-kz-node-3" "k3s.bootstrap" "k3s.kubeconfig" "k3s.prune" "incus.cluster-join" "incus.reconcile" "incus.prune" ]
[exit 0]
```

</div>

<div class="flow pt-4">
  <div class="flow-node">sops.gen<div class="sub">секреты</div></div>
  <div class="flow-arrow"><span class="line">→</span></div>
  <div class="flow-node">member-kz-node-1..3<div class="sub">nixos-rebuild</div></div>
  <div class="flow-arrow"><span class="line">→</span></div>
  <div class="flow-node">k3s.*<div class="sub">bootstrap · kubeconfig · prune</div></div>
  <div class="flow-arrow"><span class="line">→</span></div>
  <div class="flow-node accent">incus.*<div class="sub">cluster-join · reconcile · prune</div></div>
</div>

→ Кластер <code>kz-demo</code>: 3 ноды, модули <code>k3s</code> · <code>incus</code> · <code>sops</code> · <code>keepalived</code>. Вывод ниже — реальные записи с живых VM.

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
</style>

---

# Демо: converge

<div class="text-sm opacity-75 -mt-2">Одна команда: секреты → NixOS на все ноды → k3s → Incus-кластер</div>

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- converge --age-key-file secrets/kz-demo.age.key
Converging cluster 'kz-demo'
…
=== switch kz-node-1 (192.168.5.3) [nixos-rebuild] ===
…
=== step [post] k3s.kubeconfig ===
Fetching kubeconfig from 192.168.5.3...
Saved: kubeconfig/kz-demo.yaml
…
=== step [post] incus.cluster-join ===
  kz-node-2: minting single-use join token on kz-node-1
  kz-node-2: joining via incus admin init --preseed
  kz-node-2: joined
  kz-node-3: already a cluster member, skipping
```

→ В конце — одна строка <code>::nixcluster:result::</code> для машин: статус каждой ноды и каждого шага.

---

# Демо: итог converge

<div class="text-sm opacity-75 -mt-2">Машиночитаемый итог — последняя строка того же лога</div>

<div class="out-wrapline" style="--slidev-code-font-size: 11px; --slidev-code-line-height: 16px">

```text {*}{lines:false}
::nixcluster:result:: {"cluster":"kz-demo","result":"success","members":[{"name":"kz-node-1","ip":"192.168.5.3","action":"switch","status":"Applied","message":"","durationSeconds":76},{"name":"kz-node-2","ip":"192.168.5.4","action":"switch","status":"Applied","message":"","durationSeconds":7},{"name":"kz-node-3","ip":"192.168.5.5","action":"switch","status":"Applied","message":"","durationSeconds":6}],"steps":[{"name":"sops.gen","phase":"pre","status":"ok","message":""},{"name":"k3s.bootstrap","phase":"post","status":"ok","message":""},{"name":"k3s.kubeconfig","phase":"post","status":"ok","message":""},{"name":"k3s.prune","phase":"post","status":"ok","message":""},{"name":"incus.cluster-join","phase":"post","status":"ok","message":""},{"name":"incus.reconcile","phase":"post","status":"ok","message":""},{"name":"incus.prune","phase":"post","status":"ok","message":""}]}
[exit 0]
```

</div>

<div class="text-[#18C0B1] font-bold pt-1 pb-1 text-sm">Повторный converge — идемпотентно: ноды switch, join и prune — skip</div>

<div style="--slidev-code-font-size: 12px">

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- converge --age-key-file secrets/kz-demo.age.key
…
  kz-node-2: already a cluster member, skipping
  kz-node-3: already a cluster member, skipping
…
[k3s.prune] registry matches the desired members (3 entries), nothing to prune
…
```

</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
</style>

---

# Демо: Kubernetes

<div class="text-sm opacity-75 -mt-2">Три ноды k3s, все server · API через VIP keepalived</div>

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-demo.yaml --server https://192.168.5.200:6443 get nodes
NAME        STATUS   ROLES                AGE     VERSION
kz-node-1   Ready    control-plane,etcd   8m31s   v1.34.3+k3s1
kz-node-2   Ready    control-plane,etcd   3m3s    v1.34.3+k3s1
kz-node-3   Ready    control-plane,etcd   6m20s   v1.34.3+k3s1
[exit 0]
```

<div class="text-[#18C0B1] font-bold pt-2 pb-1 text-sm">VIP 192.168.5.200 висит на MASTER</div>

```text {*}{lines:false}
$ ssh root@192.168.5.3 ip --brief address show eth0
eth0             UP             192.168.5.3/24 192.168.5.200/32 fe80::5055:55ff:feb8:138c/64 
[exit 0]
```

---

# Демо: Incus-кластер

<div class="text-sm opacity-75 -mt-2">Те же три ноды — Incus-кластер собран шагом incus.cluster-join</div>

<div style="--slidev-code-font-size: 10px; --slidev-code-line-height: 14px">

```text {*}{lines:false}
$ ssh root@192.168.5.3 incus cluster list
+-----------+--------------------------+-----------------+--------------+----------------+-------------+--------+-------------------+
|   NAME    |           URL            |      ROLES      | ARCHITECTURE | FAILURE DOMAIN | DESCRIPTION | STATUS |      MESSAGE      |
+-----------+--------------------------+-----------------+--------------+----------------+-------------+--------+-------------------+
| kz-node-1 | https://192.168.5.3:8443 | database-leader | aarch64      | default        |             | ONLINE | Fully operational |
|           |                          | database        |              |                |             |        |                   |
+-----------+--------------------------+-----------------+--------------+----------------+-------------+--------+-------------------+
| kz-node-2 | https://192.168.5.4:8443 | database        | aarch64      | default        |             | ONLINE | Fully operational |
+-----------+--------------------------+-----------------+--------------+----------------+-------------+--------+-------------------+
| kz-node-3 | https://192.168.5.5:8443 | database        | aarch64      | default        |             | ONLINE | Fully operational |
+-----------+--------------------------+-----------------+--------------+----------------+-------------+--------+-------------------+
[exit 0]
```

</div>

<div class="text-[#18C0B1] font-bold pt-1 pb-1 text-sm">Запускаем контейнер</div>

<div style="--slidev-code-font-size: 12px; --slidev-code-line-height: 16px">

```text {*}{lines:false}
$ ssh root@192.168.5.3 incus launch images:alpine/edge demo
Launching demo
…
Retrieving image: rootfs: 100% (9.88MB/s)
[exit 0]
```

</div>

---

# Демо: failover VIP

<div class="text-sm opacity-75 -mt-2">До: VIP на kz-node-1 (MASTER) · гасим там keepalived — VIP переезжает, API отвечает</div>

<div style="--slidev-code-font-size: 12px; --slidev-code-line-height: 16px">

```text {*}{lines:false}
$ ssh root@192.168.5.3 systemctl stop keepalived
[exit 0]
```

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- keepalived status
INSTANCE  NODE       VIP                          HOLDS  KEEPALIVED
k3s-api   kz-node-1  192.168.5.200                no     inactive
…
k3s-api   kz-node-2  192.168.5.200                no     active
…
k3s-api   kz-node-3  192.168.5.200                yes    active
…
[exit 0]
```

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-demo.yaml --server https://192.168.5.200:6443 get nodes
NAME        STATUS   ROLES                AGE     VERSION
kz-node-1   Ready    control-plane,etcd   9m36s   v1.34.3+k3s1
kz-node-2   Ready    control-plane,etcd   4m8s    v1.34.3+k3s1
kz-node-3   Ready    control-plane,etcd   7m25s   v1.34.3+k3s1
[exit 0]
```

</div>

---

# Демо: teardown — план

<div class="text-sm opacity-75 -mt-2">Как <code>terraform destroy</code>: сначала план — шаги converge в обратном порядке</div>

<div style="--slidev-code-font-size: 11px; --slidev-code-line-height: 15px">

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- teardown --dry-run
…
  Members (each ends on its base NixOS configuration; disks are not wiped):
…
  Steps, in order:
      1. workloads  k3s.drain                      Cordon and drain every k3s node
      2. workloads  incus.instances-off            Delete every Incus instance
      3. leave      k3s.leave-kz-node-3            kz-node-3 leaves the k3s cluster and stops k3s
…
      8. leave      incus.leave-kz-node-1          kz-node-1 (bootstrap) stops Incus last
      9. cleanup    k3s.cleanup-kz-node-3          Remove k3s containers, data and config from kz-node-3
…
     23. member     member-kz-node-1               Switch kz-node-1 back to its base NixOS configuration
…
  Plan: 3 member(s) to destroy, 23 step(s).
```

</div>

<div class="text-sm pt-2 leading-snug">
→ Без <code>--dry-run</code>: тот же план, <code>Enter a value:</code> — и дальше только на&nbsp;<code>yes</code>.<br/>
→ Порядок: workloads → ноды выходят из кластеров (бутстрап последним) → cleanup → базовая NixOS.
</div>

---

# Демо: teardown → converge

<div class="text-sm opacity-75 -mt-2">Применили план: ноды на базовой NixOS · converge из того же описания собирает кластер заново</div>

<div class="out-wrapline demo-tight" style="--slidev-code-font-size: 9px; --slidev-code-line-height: 11px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- teardown --auto-approve
…
::nixcluster:result:: {"cluster":"kz-demo","result":"success","members":[{"name":"kz-node-3","ip":"192.168.5.5","action":"destroyed","status":"Applied","message":"","durationSeconds":7},{"name":"kz-node-2","ip":"192.168.5.4","action":"destroyed","status":"Applied","message":"","durationSeconds":7},{"name":"kz-node-1","ip":"192.168.5.3","action":"destroyed","status":"Applied","message":"","durationSeconds":7}],"steps":[{"name":"k3s.drain","phase":"workloads","status":"ok","message":""},{"name":"incus.instances-off","phase":"workloads","status":"ok","message":""},{"name":"k3s.leave-kz-node-3","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-3","phase":"leave","status":"ok","message":""},{"name":"k3s.leave-kz-node-2","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-2","phase":"leave","status":"ok","message":""},{"name":"k3s.leave-kz-node-1","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-1","phase":"leave","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""}]}
[exit 0]
```

</div>

<div class="text-[#18C0B1] font-bold pt-1 pb-1 text-sm">converge на чистых нодах — Incus-кластер собран заново, в k8s снова 3 Ready</div>

<div class="demo-tight" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 13px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ nix run .#cluster-kz-demo -- converge --age-key-file secrets/kz-demo.age.key
…
  kz-node-2: joined
…
  kz-node-3: joined
…
[exit 0]
```

</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---
layout: center
---

# А что, если управлять машиной кубовыми ресурсами?

<div class="text-lg opacity-85 pt-3">Машина как CRD: <code>NixosConfiguration</code> → <code>NixJob</code>, reconcile через k8s API</div>
<div class="text-2xl font-bold text-[#18C0B1] pt-5">NIO operator</div>

---

# Архитектура стека

<div class="text-sm opacity-75 -mt-2">Машина как k8s-ресурс: git → CRD → оператор → нода, reconcile замыкается на k8s API</div>

<div class="flex flex-col gap-1 pt-3 mx-auto" style="max-width: 680px;">
  <div class="grid grid-cols-2 gap-8">
    <div class="flow-node store">Git repo<div class="sub">flake.nix</div></div>
    <div class="flow-node">kubectl apply</div>
  </div>
  <div class="grid grid-cols-2 gap-8 place-items-center">
    <span class="flow-arrow"><span class="line">↓</span></span>
    <span class="flow-arrow"><span class="line">↓</span></span>
  </div>
  <div class="grid grid-cols-2 gap-8">
    <div class="flow-node">NixosConfiguration<div class="sub">CRD</div></div>
    <div class="flow-node">NixCluster<div class="sub">CRD</div></div>
  </div>
  <div class="grid grid-cols-2 gap-8 place-items-center">
    <span class="flow-arrow"><span class="line">↓</span></span>
    <span class="flow-arrow"><span class="line">↓</span></span>
  </div>
  <div class="flow-node accent">NIO operator</div>
  <div class="grid grid-cols-2 gap-8 place-items-center">
    <span class="flow-arrow"><span class="lbl">NixJob → nixos-rebuild по SSH</span><span class="line">↓</span></span>
    <span class="flow-arrow"><span class="line">↓</span></span>
  </div>
  <div class="grid grid-cols-2 gap-8">
    <div class="flow-node">NixOS node</div>
    <div class="flow-node">Machine<div class="sub">CRD</div></div>
  </div>
  <div class="grid grid-cols-2 gap-8 place-items-center">
    <span class="flow-arrow"><span class="lbl">k3s join</span><span class="line">↓</span></span>
    <span class="flow-arrow dashed"><span class="lbl">статус обратно в k8s</span><span class="line">↓</span></span>
  </div>
  <div class="flow-node accent store">Kubernetes API</div>
</div>

→ Ниже — какими примитивами это собрано.

---

# Машина как k8s-ресурс

<div class="text-sm opacity-75 -mt-2">Описываю ноду как обычный под — только вместо Docker-образа flake из git</div>

<div class="grid grid-cols-[0.85fr_1.15fr] gap-8 pt-5 items-start">
<div>
  <div class="tbl grid grid-cols-2 gap-[3px]">
    <div class="th">Kubernetes</div>
    <div class="th">NIO</div>
    <div class="rh">Deployment</div>
    <div class="win">NixDeployment</div>
    <div class="rh">Job</div>
    <div class="win">NixJob</div>
    <div class="rh">CronJob</div>
    <div class="win">NixCronJob</div>
    <div class="rh">StatefulSet</div>
    <div class="win">NixStatefulSet</div>
  </div>
  <div class="text-xs opacity-60 pt-2">Те же кайнды k8s — только из флейка, а не из образа</div>
</div>
<div class="text-sm">
  <div class="text-[#18C0B1] font-bold pb-1">Ноду тоже описываю ресурсом</div>
  <div class="opacity-85 leading-snug pb-3">Кладу <code>NixosConfiguration</code> — NIO сам делает <code>nixos-rebuild</code> на&nbsp;ноду. Руками по SSH не хожу.</div>
  <div class="flex flex-col gap-2 leading-snug">
    <div><span class="text-[#18C0B1] font-bold">→</span> Управляю через <code>kubectl</code>, RBAC, логи — как любым ресурсом</div>
    <div><span class="text-[#18C0B1] font-bold">→</span> Тем же способом катятся и сами сервисы</div>
    <div><span class="text-[#18C0B1] font-bold">→</span> Никакого Dockerfile и registry</div>
  </div>
</div>
</div>

---

# NixosConfiguration: не только раскат

<div class="text-sm opacity-75 -mt-2">Две находки из реализации — уже гоняю в проде</div>

<div class="grid grid-cols-2 gap-6 pt-5">
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-2">Данные ноды — на лету</div>
    <div class="text-sm opacity-85 leading-snug pb-2">Конфиг в git — общий, без привязки к конкретной машине. В момент раската NIO подмешивает файлы прямо в дерево:</div>
    <div class="flex flex-col gap-1.5 text-sm leading-snug">
      <div><span class="text-[#18C0B1]">•</span> <b>железо ноды</b> — из nixos-facter</div>
      <div><span class="text-[#18C0B1]">•</span> <b>секреты</b> — из k8s Secret</div>
      <div><span class="text-[#18C0B1]">•</span> <b>inline</b> — точечные куски конфига</div>
    </div>
    <div class="text-xs opacity-70 pt-2">→ Секреты не в git, железо не хардкодишь — одна база на&nbsp;любую ноду.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-2">Вайп при выводе ноды</div>
    <div class="text-sm opacity-85 leading-snug pb-2">У ресурса два конца: во что ноду <b>превратить</b> — и&nbsp;во&nbsp;что <b>вернуть</b>, когда выводишь из кластера.</div>
    <div class="text-sm leading-snug">Удалил <code>NixosConfiguration</code> → NIO последним раскатом катит <code>onRemoveFlake</code> (напр. <code>#minimal</code>).</div>
    <div class="text-xs opacity-70 pt-2">→ Вывод ноды декларативный: не «забыть машину», а&nbsp;вернуть к чистому состоянию.</div>
  </div>
</div>

<div class="text-xs opacity-60 pt-5">
Под капотом — <code>NixCronJob</code>: <code>nixos-rebuild switch</code> по расписанию и сразу на новый коммит.<br/>
Уже в операторе: <code>spec.additionalFiles</code> (Inline · SecretRef · NixosFacter) · <code>spec.onRemoveFlake</code>
</div>

---

# NixCluster: описываю классы нод

<div class="text-sm opacity-75 -mt-2">Не ноды по одной — группы: control-plane, data-plane, gpu…</div>

<div class="grid grid-cols-2 gap-4 pt-5">
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Группы, а не машины</div>
    <div class="text-sm opacity-85"><code>control-plane</code>, <code>data-plane</code>, <code>gpu-pool</code> — сколько угодно. Для каждой: сколько нод и по какому критерию.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Спека группы — три поля</div>
    <div class="text-sm opacity-85"><code>selector</code> + <code>count</code> + <code>values</code>. Оператор берёт <code>Machine</code> по лейблам, <code>count</code> — потолок группы.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">values → members.&lt;нода&gt;</div>
    <div class="text-sm opacity-85">Содержимое группы прилетает прямо в тот же <code>nixcluster</code> из первой части — один язык на обе половины.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Шаблон — flake-parts</div>
    <div class="text-sm opacity-85">На лету подсасывает куски инфры: добавил описание — оно уже в деле.</div>
  </div>
</div>

<div class="text-sm opacity-80 pt-5 max-w-5xl">
Сказал: <b>3 control-plane + 5 data-plane</b> — получил кластер. Оператор разложил конфиги по нодам сам.
</div>

---

# Коммит → раскатилось само

<div class="text-sm opacity-75 -mt-2">Git — источник правды, NIO приводит машину к нему</div>

<div class="flow pt-12">
  <div class="flow-node">git push<div class="sub">поменял конфиг ноды</div></div>
  <div class="flow-arrow"><span class="line">→</span></div>
  <div class="flow-node accent">NIO заметил<div class="sub">новый коммит</div></div>
  <div class="flow-arrow"><span class="line">→</span></div>
  <div class="flow-node">Нода = git<div class="sub">nixos-rebuild сам</div></div>
</div>

<div class="grid grid-cols-3 gap-4 pt-12 text-sm">
  <div class="rounded-lg p-3 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Self-heal</div>
    <div class="opacity-85">Ушла от git — вернётся сама, без&nbsp;моего участия.</div>
  </div>
  <div class="rounded-lg p-3 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Откат</div>
    <div class="opacity-85">Вернул прошлый коммит — вернулась и нода.</div>
  </div>
  <div class="rounded-lg p-3 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Сборка — в кластере</div>
    <div class="opacity-85">Собирается на кластере, не&nbsp;на&nbsp;моём ноуте.</div>
  </div>
</div>

---

# Демо: NIO — kubectl apply

<div class="text-sm opacity-75 -mt-2">Три <code>Machine</code> + один <code>NixCluster</code> на том же flake <code>kz-demo</code> · NIO сам завёл converge</div>

<div class="demo-tight" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 13px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml apply --server-side --filename nio/
machine.nio.homystack.com/kz-node-1 serverside-applied
machine.nio.homystack.com/kz-node-2 serverside-applied
machine.nio.homystack.com/kz-node-3 serverside-applied
nixcluster.nio.homystack.com/kz-demo serverside-applied
[exit 0]
```

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get machines,nixclusters,nixcronjobs,jobs
NAME                                  HOST          READY   DISCOVERABLE   CONFIG   AGE
machine.nio.homystack.com/kz-node-1   192.168.5.3   True    True                    38m
machine.nio.homystack.com/kz-node-2   192.168.5.4   True    True                    38m
machine.nio.homystack.com/kz-node-3   192.168.5.5   True    True                    38m

NAME                                   PHASE   CONVERGE           TEARDOWN   AGE
nixcluster.nio.homystack.com/kz-demo   Ready   kz-demo-converge              38m

NAME                                            PHASE   SCHEDULE    LASTSCHEDULE   AGE
nixcronjob.nio.homystack.com/kz-demo-converge   Ready   0 3 * * *   6m8s           38m

NAME                                               STATUS     COMPLETIONS   DURATION   AGE
job.batch/kz-demo-converge-r-26e34252e4eb-manual   Complete   1/1           10m        10m
[exit 0]
```

</div>

<style>
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---

# Демо: NIO — converge в поде

<div class="text-sm opacity-75 -mt-2">Job создал оператор: тот же <code>nix run .#cluster-kz-demo -- converge</code>, только в поде</div>

<div class="out-wrapline demo-tight" style="--slidev-code-font-size: 11px; --slidev-code-line-height: 15px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml logs job/kz-demo-converge-r-26e34252e4eb-manual --container app
…
[ssh] installed cluster identity from NIX_SSHOPTS at /root/.ssh/id_ed25519
Converging cluster 'kz-demo'
…
=== switch kz-node-1 (192.168.5.3) [nixos-rebuild] ===
…
  kz-node-2: already a cluster member, skipping
  kz-node-3: already a cluster member, skipping
…
::nixcluster:result:: {"cluster":"kz-demo","result":"success","members":[{"name":"kz-node-1","ip":"192.168.5.3","action":"switch","status":"Applied","message":"","durationSeconds":380},{"name":"kz-node-2","ip":"192.168.5.4","action":"switch","status":"Applied","message":"","durationSeconds":32},{"name":"kz-node-3","ip":"192.168.5.5","action":"switch","status":"Applied","message":"","durationSeconds":20}],"steps":[{"name":"sops.gen","phase":"pre","status":"ok","message":""},{"name":"k3s.bootstrap","phase":"post","status":"ok","message":""},{"name":"k3s.kubeconfig","phase":"post","status":"ok","message":""},{"name":"k3s.prune","phase":"post","status":"ok","message":""},{"name":"incus.cluster-join","phase":"post","status":"ok","message":""},{"name":"incus.reconcile","phase":"post","status":"ok","message":""},{"name":"incus.prune","phase":"post","status":"ok","message":""}]}
[exit 0]
```

</div>

<div class="text-xs opacity-60 pt-1">Кластер уже собран CLI из первой части — converge идемпотентен: ноды switch, join и prune — skip</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---

# Демо: NIO — коммит → раскатилось

<div class="text-sm opacity-75 -mt-2">Поменял motd в git · NIO увидел новый коммит и запустил converge, не дожидаясь расписания</div>

<div class="out-wrapline demo-tight" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 13px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ git --no-pager diff
…
+++ b/modules/clusters/kz-demo.nix
…
+        users.motd = "kz-demo: rolled out by NIO from git";
…
```

```text {*}{lines:false}
$ git commit --all --message "kz-demo: set a motd" && git push origin main
[main 2dc4933] kz-demo: set a motd
…
   249d84a..2dc4933  main -> main
```

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixcronjob,jobs
…
NAME                                               STATUS     COMPLETIONS   DURATION   AGE
job.batch/kz-demo-converge-r-26e34252e4eb-manual   Complete   1/1           10m        11m
job.batch/kz-demo-converge-r-6580f92a1dc7-manual   Running    0/1           1s         1s
[exit 0]
```

```text {*}{lines:false}
$ ssh root@192.168.5.3 'grep --only-matching "motd=[^ ]*" /etc/pam.d/sshd | cut --delimiter== --fields=2 | xargs cat; echo'
kz-demo: rolled out by NIO from git
[exit 0]
```

</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---

# Демо: NIO — delete → teardown

<div class="text-sm opacity-75 -mt-2"><code>deletionPolicy: Teardown</code> (дефолт): финализер ждёт teardown · <code>Retain</code>: только k8s-объекты</div>

<div class="out-wrapline demo-tight" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 13px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml delete nixcluster kz-demo --wait=false
nixcluster.nio.homystack.com "kz-demo" deleted from default namespace
[exit 0]
```

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixcluster,nixcronjobs,nixjobs,jobs
NAME                                   PHASE         CONVERGE           TEARDOWN   AGE
nixcluster.nio.homystack.com/kz-demo   TearingDown   kz-demo-converge   Running    46m
…
NAME                                        PHASE         REVISION   SUCCEEDED   AGE
nixjob.nio.homystack.com/kz-demo-teardown   Progressing                          21s
…
job.batch/kz-demo-teardown-r-5523d26b33a2          Running    0/1           20s        20s
[exit 0]
```

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml logs --follow job/kz-demo-teardown-r-5523d26b33a2 --container app
…
  Plan: 3 member(s) to destroy, 23 step(s).
…
Tearing down cluster 'kz-demo'
…
=== switch kz-node-1 (192.168.5.3) back to its base configuration ===
…
```

</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---

# Демо: NIO — объект ушёл, ноды чистые

<div class="text-sm opacity-75 -mt-2">Teardown-джоба: success → финализер снят · на нодах ни k3s, ни Incus · <code>Machine</code> остались</div>

<div class="out-wrapline demo-tight" style="--slidev-code-font-size: 9px; --slidev-code-line-height: 11px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
::nixcluster:result:: {"cluster":"kz-demo","result":"success","members":[{"name":"kz-node-3","ip":"192.168.5.5","action":"destroyed","status":"Applied","message":"","durationSeconds":100},{"name":"kz-node-2","ip":"192.168.5.4","action":"destroyed","status":"Applied","message":"","durationSeconds":12},{"name":"kz-node-1","ip":"192.168.5.3","action":"destroyed","status":"Applied","message":"","durationSeconds":11}],"steps":[{"name":"k3s.drain","phase":"workloads","status":"ok","message":""},{"name":"incus.instances-off","phase":"workloads","status":"ok","message":""},{"name":"k3s.leave-kz-node-3","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-3","phase":"leave","status":"ok","message":""},{"name":"k3s.leave-kz-node-2","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-2","phase":"leave","status":"ok","message":""},{"name":"k3s.leave-kz-node-1","phase":"leave","status":"ok","message":""},{"name":"incus.leave-kz-node-1","phase":"leave","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-3","phase":"cleanup","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-2","phase":"cleanup","status":"ok","message":""},{"name":"k3s.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"incus.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"keepalived.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""},{"name":"sops.cleanup-kz-node-1","phase":"cleanup","status":"ok","message":""}]}
[exit 0]
```

</div>

<div class="demo-tight" style="--slidev-code-font-size: 10px; --slidev-code-line-height: 13px; --slidev-code-padding: 6px 14px">

```text {*}{lines:false}
$ kubectl --kubeconfig kubeconfig/kz-mgmt.yaml get nixclusters,nixcronjobs,nixjobs,jobs
No resources found in default namespace.
[exit 0]
```

```text {*}{lines:false}
$ ssh root@192.168.5.3 'systemctl is-active k3s incus keepalived; ls /var/lib/rancher /var/lib/incus'
inactive
inactive
inactive
ls: cannot access '/var/lib/rancher': No such file or directory
ls: cannot access '/var/lib/incus': No such file or directory
[exit 2]
```

</div>

<style>
.out-wrapline pre, .out-wrapline code { white-space: pre-wrap !important; word-break: break-all; }
.demo-tight .slidev-code-wrapper { margin: 5px 0; }
</style>

---

# Что получилось

> Кластер, который **сам себя масштабирует, восстанавливает и обновляет** —
> без внешних систем и&nbsp;без&nbsp;жертв в виде отладочных инструментов.

<div class="grid grid-cols-4 gap-3 pt-5">
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">1 git</div>
    <div class="text-sm opacity-85">источник правды для&nbsp;нод и сервисов</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">0 внешних систем</div>
    <div class="text-sm opacity-85">reconcile живёт внутри куба</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Прод жив</div>
    <div class="text-sm opacity-85">сломал сборку — чинишь в git, не&nbsp;в&nbsp;проде</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Нода = ресурс</div>
    <div class="text-sm opacity-85">от «хочу» до Ready без&nbsp;ручного SSH</div>
  </div>
</div>

---

# Классика → Talos → мой стек

<div class="tbl grid grid-cols-[1.1fr_1.3fr_1.4fr_1.4fr] gap-[3px] pt-3 text-[0.8rem]">
  <div class="th">Ось</div>
  <div class="th">Ubuntu / Debian</div>
  <div class="th">Talos</div>
  <div class="th">Мой стек · NIO + nixcluster</div>

  <div class="rh">Конфигурация</div>
  <div>Ansible / cloud-init</div>
  <div>machineconfig.yaml</div>
  <div class="win">NixosConfiguration</div>

  <div class="rh">Atomic + rollback</div>
  <div><span class="no">✗</span> in-place apt</div>
  <div><span class="yes">✓</span> A/B image</div>
  <div class="win"><span class="yes">✓</span> NixOS generations</div>

  <div class="rh">Воспроизводимость</div>
  <div>snowflake</div>
  <div><span class="yes">✓</span></div>
  <div class="win"><span class="yes">✓</span> flake.lock</div>

  <div class="rh">SSH / debug</div>
  <div><span class="yes">✓</span></div>
  <div><span class="no">✗</span></div>
  <div class="win"><span class="yes">✓</span></div>

  <div class="rh">Kernel / GPU</div>
  <div><span class="yes">✓</span> любые</div>
  <div>limited, version-lock</div>
  <div class="win"><span class="yes">✓</span> любые, из nixpkgs</div>

  <div class="rh">k8s-bootstrap</div>
  <div>kubeadm руками</div>
  <div><span class="yes">✓</span> встроен</div>
  <div class="win"><span class="yes">✓</span> nixos-anywhere + k3s</div>

  <div class="rh">Не только k8s</div>
  <div><span class="yes">✓</span></div>
  <div><span class="no">✗</span> k8s-only</div>
  <div class="win"><span class="yes">✓</span> VM / Incus / сервисы</div>

  <div class="rh">Self-heal</div>
  <div><span class="no">✗</span> Ansible-прогон</div>
  <div>partial</div>
  <div class="win"><span class="yes">✓</span> reconcile loop</div>
</div>

→ Классика гибкая, но мутабельная. Talos atomic, но закрытый.
Стек берёт **оба** свойства.

---

# Как я управляю кластером

<div class="text-sm opacity-75 -mt-2">Дофантазировка: день, когда оба слоя сошлись — <code>git</code> становится единственным пультом</div>

<div class="grid grid-cols-2 gap-4 pt-5">
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Новый сервис</div>
    <div class="text-sm opacity-85">Показываю на git repo + <code>.#attr</code> — работает. Без&nbsp;Dockerfile, без registry, без отдельного CI образов.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Обновление</div>
    <div class="text-sm opacity-85"><code>git push</code> → оператор увидел коммит → сам раскатил. Ноды и приложения — одним движением.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Откат</div>
    <div class="text-sm opacity-85">Вернул прошлый коммит — откат мгновенный, всё&nbsp;уже собрано.</div>
  </div>
  <div class="rounded-lg p-4 bg-white/5">
    <div class="font-bold text-[#18C0B1] pb-1">Сломал сборку</div>
    <div class="text-sm opacity-85">Rollout встал в init, прод крутит старое. Чиню в git, не в проде.</div>
  </div>
</div>

<div class="text-sm opacity-80 pt-5 max-w-3xl">
Один <code>git</code>, один язык, один reconcile — <b>и для ноды, и для приложения на ней</b>.
</div>

---
layout: section
number: "02"
---

# Tradeoffs
## Честно — где цена

---

# Сколько занимает сборка

<div class="text-sm opacity-75 -mt-2">Обычно пару минут. Но cache miss — десятки: держи в голове</div>

<div class="grid grid-cols-[1.15fr_0.85fr] gap-6 pt-4 items-center">
<div>
  <div class="chart" style="height:230px; margin:0 0.5rem 3rem 2rem;">
    <div class="grid" style="bottom:100%"></div><div class="glabel" style="bottom:100%">40м</div>
    <div class="grid" style="bottom:50%"></div><div class="glabel" style="bottom:50%">20м</div>
    <div class="grid" style="bottom:0"></div><div class="glabel" style="bottom:0">0</div>
    <div class="col good" style="left:18%;height:5%"><div class="cap">~2м</div><div class="nm">тёплый кэш<br/>обычный switch</div></div>
    <div class="col good" style="left:50%;height:17.5%"><div class="cap">~7м</div><div class="nm">частичный кэш<br/>бампнул пакет</div></div>
    <div class="col bad" style="left:82%;height:75%"><div class="cap">~30м</div><div class="nm">cache miss<br/>собирается мир</div></div>
  </div>
</div>
<div class="text-sm">
  <div class="rounded-lg px-3 py-2 bg-[#f0907f]/12 border border-[#f0907f]/40 leading-snug">
    <div class="font-bold text-[#f0907f] pb-1">Cache miss = обрыв</div>
    ≈ <b>20 ГБ</b> скачать. А среди зависимостей — <b>LLVM</b>, чтобы собрать одну вещь. Десятки минут.
  </div>
  <div class="rounded-lg px-3 py-2 bg-[#18C0B1]/10 border border-[#18C0B1]/40 leading-snug mt-3">
    <div class="font-bold text-[#18C0B1] pb-1">Спасает binary cache</div>
    Тёплый store (cache.nixos.org / свой) → снова пара минут. Но первый раз или редкий пакет — готовься.
  </div>
</div>
</div>

---

# Безопасность: честный размен

<div class="text-sm opacity-75 -mt-2">Generic-ОС «делай что угодно» — это не минимальный appliance. И это осознанно</div>

<div class="grid grid-cols-2 gap-6 pt-5">
  <div class="rounded-lg p-4 bg-[#f0907f]/12 border border-[#f0907f]/40">
    <div class="font-bold text-[#f0907f] pb-2">Поверхность атаки больше</div>
    <div class="flex flex-col gap-1.5 text-sm leading-snug">
      <div><span class="text-[#f0907f]">•</span> Полный Linux, а не read-only squashfs-appliance</div>
      <div><span class="text-[#f0907f]">•</span> SSH на ноды — у Talos только gRPC API</div>
      <div><span class="text-[#f0907f]">•</span> Root, пакеты, ядро — всё живое и доступное</div>
      <div><span class="text-[#f0907f]">•</span> «Могу всё» = есть что атаковать</div>
    </div>
  </div>
  <div class="rounded-lg p-4 bg-[#18C0B1]/10 border border-[#18C0B1]/40">
    <div class="font-bold text-[#18C0B1] pb-2">Но гибкость = контроль</div>
    <div class="flex flex-col gap-1.5 text-sm leading-snug">
      <div><span class="text-[#18C0B1]">•</span> Вся система в git — аудит и ревью как код</div>
      <div><span class="text-[#18C0B1]">•</span> Воспроизводимо (flake.lock) — без снежинок и&nbsp;дрифта</div>
      <div><span class="text-[#18C0B1]">•</span> Store иммутабелен, откат атомарный</div>
      <div><span class="text-[#18C0B1]">•</span> Секреты через sops — не в git</div>
      <div><span class="text-[#18C0B1]">•</span> Профиль можно урезать под минимум</div>
    </div>
  </div>
</div>

<div class="text-sm opacity-80 pt-5 max-w-3xl">
→ Нужен минимальный attack surface любой ценой — это Talos. Нужна гибкость — платишь
поверхностью, но получаешь <b>прозрачность и контроль</b>.
</div>

---

# Что было сложно и кому НЕ&nbsp;подходит

<div class="grid grid-cols-2 gap-8">
<div>

**Цена стека:**

- Bootstrap первого control-plane — chicken-and-egg
- SSH-based reconcile: ключи нужно ротейтить
- Learning curve Nix — инвестиция для команды

</div>
<div>

**Кому НЕ подходит:**

- Команда новичков в Linux
- Hyperscale homogeneous-кластер, где Talos закрывает 100%
- Регуляторика «minimal OS»-сертификации
- «Включил и забыл» — это не про нас

</div>
</div>

→ Каждый инструмент под свою задачу. Я выбрал гибкость.

---
layout: center
---

# Спасибо

Стек: github.com/kitsunoff/NIO + github.com/kitsunoff/nixcluster

Слайды: github.com/kitsunoff/nixos-for-kubernetes

**Вопросы?**

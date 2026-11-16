<template>
  <div v-if="$nav.currentLayout !== 'cover' && $nav.currentPage > 1" class="kz-chrome">
    <span class="kz-crumb">03 / NixOS как KubernetesOS</span>
    <span class="kz-page">{{ String($nav.currentPage).padStart(2, '0') }}</span>
  </div>
</template>

<style scoped>
.kz-chrome {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 40;
  font-family: var(--kz-font);
}

/* section-index tape label, top-left on the page margin */
.kz-crumb {
  position: absolute;
  left: var(--kz-margin);
  top: 16px;
  padding: 4px 8px;
  background: var(--kz-accent);
  color: var(--kz-ink);
  font-size: 10px;
  font-weight: 700;
  line-height: 1;
  letter-spacing: 0.02em;
  text-transform: uppercase;
  box-shadow: 3px 3px 0 var(--kz-ink);
}

/* zero-padded page index, like the row numbers of the programme */
.kz-page {
  position: absolute;
  right: var(--kz-margin);
  bottom: 14px;
  font-size: 12px;
  font-weight: 700;
  color: var(--kz-index);
}
</style>

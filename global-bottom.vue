<template>
  <div class="kc-chrome">
    <img src="/theme/logo.png" class="kc-logo" alt="KUBERNETES COMMUNITY" />
    <div v-if="currentPage > 1" class="kc-page">{{ currentPage }}</div>
  </div>
</template>

<script setup>
import { useNav } from '@slidev/client'
const { currentPage } = useNav()
</script>

<style scoped>
.kc-chrome {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 40;
}

/* exact template geometry: logo x=80.2% y=5.4% w=15.8% */
.kc-logo {
  position: absolute;
  left: 80.2%;
  top: 5.4%;
  width: 15.8%;
  opacity: 0.95;
}

/* slide number: x=94.5% y=93.5%, Verdana 11pt white */
.kc-page {
  position: absolute;
  left: 94.5%;
  top: 93.5%;
  font-size: 0.7rem;
  font-family: var(--slidev-font-sans);
  color: rgba(255, 255, 255, 0.85);
}
</style>

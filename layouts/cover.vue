<template>
  <div class="kc-cover">
    <div class="kc-cover-body">
      <slot />
    </div>
    <img src="/theme/cube.png" class="kc-cube" alt="" />
  </div>
</template>

<style scoped>
.kc-cover {
  position: relative;
  height: 100%;
  width: 100%;
  background: #000;
  color: #fff;
  font-family: var(--slidev-font-sans);
  padding: 4.5rem 4rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  overflow: hidden;
}

.kc-cover-body {
  position: relative;
  z-index: 2;
  max-width: 60%;
}

.kc-cover-body :deep(h1) {
  font-family: var(--slidev-font-sans);
  font-size: 2.9rem;
  font-weight: 700;
  line-height: 1.05;
  margin-bottom: 1rem;
}

.kc-cover-body :deep(p) {
  font-size: 1.1rem;
  opacity: 0.8;
}

/* cube — template title geometry: x=62.5% y=4.8% w=28.3% */
.kc-cube {
  position: absolute;
  left: 62.5%;
  top: 4.8%;
  width: 28.3%;
  opacity: 0.95;
  pointer-events: none;
  z-index: 1;
}
</style>

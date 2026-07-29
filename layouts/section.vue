<template>
  <div class="kc-section">
    <div class="kc-num">| {{ $frontmatter.number || '01' }}</div>
    <div class="kc-section-body">
      <slot />
    </div>
    <img src="/theme/cube.png" class="kc-cube" alt="" />
  </div>
</template>

<style scoped>
.kc-section {
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

.kc-num {
  position: relative;
  z-index: 2;
  font-size: 3.4rem;
  font-weight: 800;
  line-height: 1;
  color: var(--brand-accent);
  margin-bottom: 1.5rem;
}

.kc-section-body {
  position: relative;
  z-index: 2;
  max-width: 72%;
}

.kc-section-body :deep(h1) {
  font-size: 2.8rem;
  line-height: 1.1;
  margin-bottom: 0.5rem;
}

.kc-section-body :deep(h2) {
  font-size: 1.15rem;
  font-weight: 500;
  opacity: 0.7;
}

.kc-cube {
  position: absolute;
  right: 1.5rem;
  bottom: 0.5rem;
  width: 30%;
  max-width: 340px;
  opacity: 0.95;
  pointer-events: none;
  z-index: 1;
}
</style>

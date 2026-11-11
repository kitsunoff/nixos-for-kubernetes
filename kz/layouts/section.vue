<template>
  <div class="slidev-layout kz-section">
    <div class="kz-section-eyebrow">Блок {{ $frontmatter.number || '01' }}</div>
    <div class="kz-section-body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.kz-section {
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 58px var(--kz-margin) 40px;
}

/* block eyebrow: small uppercase ink caption */
.kz-section-eyebrow {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.02em;
  text-transform: uppercase;
  color: var(--kz-ink);
  margin-bottom: 10px;
}

/* block title closed by a full-width rule */
.kz-section-body :deep(h1) {
  margin: 0;
  padding-bottom: 18px;
  max-width: 100%;
  border-bottom: var(--kz-rule-w) solid var(--kz-rule);
  font-size: 64px;
  font-weight: 800;
  font-stretch: 75%;
  line-height: 1.02;
  text-transform: uppercase;
}

/* subtitle below the rule as a `// comment` row */
.kz-section-body :deep(h2) {
  margin: 0;
  padding: 20px 0;
  border-bottom: var(--kz-rule-w) solid var(--kz-rule);
  font-size: 22px;
  font-weight: 500;
  line-height: 1.3;
  text-transform: none;
}

.kz-section-body :deep(h2)::before {
  content: '// ';
  color: var(--kz-index);
}
</style>

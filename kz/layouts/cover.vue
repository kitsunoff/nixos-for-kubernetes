<template>
  <div class="slidev-layout kz-cover">
    <div class="kz-cover-head">
      <span v-if="$frontmatter.eyebrow" class="kz-tag kz-tag--shadow">{{ $frontmatter.eyebrow }}</span>
      <slot />
    </div>
    <div class="kz-cover-row">
      <span class="kz-cover-idx">03</span>
      <span class="kz-cover-name">{{ $frontmatter.speaker }}</span>
      <span class="kz-cover-note">{{ $frontmatter.role }}</span>
    </div>
  </div>
</template>

<style scoped>
.kz-cover {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 26px var(--kz-margin) 34px;
}

.kz-cover-head {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding-bottom: 26px;
  border-bottom: var(--kz-rule-w) solid var(--kz-rule);
}

/* display heading: huge, heavy, condensed, uppercase */
.kz-cover-head :deep(h1) {
  margin: 22px 0 22px;
  padding: 0;
  border: none;
  max-width: 100%;
  font-size: 76px;
  font-weight: 800;
  font-stretch: 75%;
  line-height: 1;
  letter-spacing: -0.01em;
  text-transform: uppercase;
  color: var(--kz-fg);
}

/* the subtitle paragraph becomes a `// comment` tape label */
.kz-cover-head :deep(h1 + p) {
  display: inline-block;
  margin: 0;
  padding: 6px 10px;
  background: var(--kz-accent);
  color: var(--kz-ink);
  font-size: 15px;
  font-weight: 700;
  line-height: 1.2;
  opacity: 1;
}

.kz-cover-head :deep(h1 + p)::before {
  content: '// ';
}

/* one programme row: index · speaker · talk */
.kz-cover-row {
  display: grid;
  grid-template-columns: 66px 1fr 1fr;
  align-items: baseline;
  padding: 22px 0;
  border-top: var(--kz-rule-w) solid var(--kz-rule);
  border-bottom: var(--kz-rule-w) solid var(--kz-rule);
}

.kz-cover-idx {
  font-size: 13px;
  font-weight: 700;
  color: var(--kz-index);
}

.kz-cover-name {
  font-size: 22px;
  font-weight: 700;
}

.kz-cover-note {
  font-size: 22px;
  font-weight: 500;
}
</style>

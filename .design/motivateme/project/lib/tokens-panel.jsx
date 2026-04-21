// tokens-panel.jsx — visual tokens reference panel shown from Tweaks

function TokensPanel({ t, onClose, hue, setHue, dark, setDark, motion, setMotion, demoState, setDemoState }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 200 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.35)' }}/>
      <div style={{
        position: 'absolute', right: 12, top: 12, bottom: 12, width: 340,
        background: t.color.surfaceModal, borderRadius: 22, boxShadow: t.elev.xl,
        display: 'flex', flexDirection: 'column', overflow: 'hidden',
      }}>
        <div style={{ padding: '16px 18px 12px', borderBottom: `0.5px solid ${t.color.separator}`,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ ...typeStyle(t.type.title3, t.family), color: t.color.textPrimary }}>Tweaks</div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>Morning Light system</div>
          </div>
          <button onClick={onClose} style={{ border: 'none', background: t.color.surfaceInput,
            width: 28, height: 28, borderRadius: 14, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="close" size={14} color={t.color.textSecondary} strokeWidth={2.2}/>
          </button>
        </div>

        <div style={{ flex: 1, overflow: 'auto', padding: '14px 16px 20px' }}>
          {/* Dark mode */}
          <Section t={t} title="Appearance">
            <RowBlock t={t} label="Dark mode">
              <MMToggle t={t} on={dark} onChange={setDark}/>
            </RowBlock>
            <RowBlock t={t} label="Motion">
              <MMSegmented t={t}
                options={[{ value: 'full', label: 'Full' }, { value: 'reduced', label: 'Reduced' }]}
                value={motion} onChange={setMotion}/>
            </RowBlock>
          </Section>

          {/* Demo state */}
          <Section t={t} title="Demo state">
            <RowBlock t={t} label="Simulate">
              <MMSegmented t={t}
                options={[
                  { value: 'populated', label: 'Day 13' },
                  { value: 'dayOne',    label: 'Day 1' },
                ]}
                value={demoState || 'populated'} onChange={setDemoState}/>
            </RowBlock>
            <div style={{ padding: '8px 12px 0', ...typeStyle(t.type.caption2, t.family),
              color: t.color.textTertiary, fontStyle: 'italic', lineHeight: 1.4 }}>
              Day 1 shows what a brand-new user sees — empty states, no streaks, first habits.
            </div>
          </Section>

          {/* Hue */}
          <Section t={t} title="Primary hue">
            <div style={{ display: 'flex', gap: 8 }}>
              {[
                { k: 'peach', label: 'Peach' },
                { k: 'honey', label: 'Honey' },
                { k: 'terracotta', label: 'Terracotta' },
              ].map(h => {
                const tt = MMTokens(h.k, dark);
                const sel = hue === h.k;
                return (
                  <button key={h.k} onClick={() => setHue(h.k)} style={{
                    flex: 1, padding: '10px 6px', borderRadius: 14, border: 'none', cursor: 'pointer',
                    background: sel ? tt.color.primaryMuted : t.color.surfaceInput,
                    outline: sel ? `1.5px solid ${tt.color.primary}` : 'none', outlineOffset: -1.5,
                    display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                  }}>
                    <div style={{ width: 28, height: 28, borderRadius: 8, background: tt.color.primary }}/>
                    <span style={{ fontFamily: t.family.rounded, fontSize: 12, fontWeight: 600,
                      color: sel ? tt.color.primary : t.color.textSecondary }}>{h.label}</span>
                  </button>
                );
              })}
            </div>
          </Section>

          {/* Color swatches */}
          <Section t={t} title="Semantic colors">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
              {[
                ['Primary', t.color.primary],
                ['Secondary', t.color.secondary],
                ['Success', t.color.success],
                ['Warning', t.color.warning],
                ['Info', t.color.info],
                ['Error', t.color.error],
              ].map(([name, c]) => (
                <div key={name} style={{ display: 'flex', alignItems: 'center', gap: 8,
                  padding: 8, borderRadius: 10, background: t.color.surfaceInput }}>
                  <div style={{ width: 22, height: 22, borderRadius: 6, background: c, boxShadow: 'inset 0 0 0 0.5px rgba(0,0,0,0.08)' }}/>
                  <span style={{ fontFamily: t.family.text, fontSize: 12, color: t.color.textSecondary }}>{name}</span>
                </div>
              ))}
            </div>
          </Section>

          {/* Surfaces */}
          <Section t={t} title="Surface elevation">
            <div style={{ display: 'flex', gap: 8 }}>
              {['bg','surface','surfaceCard','surfaceElevated','surfaceModal'].map(k => (
                <div key={k} style={{ flex: 1, height: 56, borderRadius: 10,
                  background: t.color[k], boxShadow: t.elev.sm,
                  display: 'flex', alignItems: 'flex-end', justifyContent: 'center', padding: 6 }}>
                  <span style={{ fontFamily: t.family.mono, fontSize: 9, color: t.color.textTertiary }}>
                    {k.replace('surface','')||'bg'}
                  </span>
                </div>
              ))}
            </div>
          </Section>

          {/* Type */}
          <Section t={t} title="Type scale">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, padding: 12, borderRadius: 12, background: t.color.surfaceInput }}>
              {[
                ['Large Title', t.type.largeTitle],
                ['Title 1', t.type.title1],
                ['Title 2', t.type.title2],
                ['Headline', t.type.headline],
                ['Body', t.type.body],
                ['Footnote', t.type.footnote],
                ['Caption 2', t.type.caption2],
              ].map(([name, tok]) => (
                <div key={name} style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
                  <span style={{ ...typeStyle(tok, t.family), color: t.color.textPrimary, flex: 1 }}>{name}</span>
                  <span style={{ fontFamily: t.family.mono, fontSize: 10, color: t.color.textTertiary }}>
                    {tok.size}/{tok.lh} {tok.weight}
                  </span>
                </div>
              ))}
            </div>
          </Section>

          {/* Radii */}
          <Section t={t} title="Radii">
            <div style={{ display: 'flex', gap: 6 }}>
              {['sm','md','lg','card','cardLg','sheet'].map(k => (
                <div key={k} style={{ flex: 1, height: 48, background: t.color.primaryMuted,
                  borderRadius: t.radius[k],
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: t.family.mono, fontSize: 10, color: t.color.primary }}>{t.radius[k]}</div>
              ))}
            </div>
          </Section>

          {/* Voice & tone */}
          <Section t={t} title="Voice & tone">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6, ...typeStyle(t.type.footnote, t.family) }}>
              {[
                ['Streak broken', '"Streaks end. Showing up again is the hard part — and you just did."'],
                ['First check-in', '"You showed up. That\'s the whole thing."'],
                ['Weekly summary', '"Four out of seven. That\'s a lot of small yeses."'],
                ['Missed day', '"Yesterday was yesterday. Today is new."'],
                ['Streak extended', '"Day 12. Steady wins this."'],
              ].map(([k, v]) => (
                <div key={k} style={{ padding: 10, borderRadius: 10, background: t.color.surfaceInput }}>
                  <div style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 600, color: t.color.textTertiary,
                    textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 3 }}>{k}</div>
                  <div style={{ color: t.color.textPrimary, fontStyle: 'italic' }}>{v}</div>
                </div>
              ))}
            </div>
          </Section>
        </div>
      </div>
    </div>
  );
}

function Section({ t, title, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.6,
        color: t.color.textTertiary, textTransform: 'uppercase', marginBottom: 8, padding: '0 2px' }}>
        {title}
      </div>
      {children}
    </div>
  );
}

function RowBlock({ t, label, children }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '10px 12px', borderRadius: 12, background: t.color.surfaceInput, marginBottom: 6, gap: 12 }}>
      <span style={{ ...typeStyle(t.type.body, t.family), color: t.color.textPrimary }}>{label}</span>
      <div style={{ flexShrink: 0, minWidth: 120 }}>{children}</div>
    </div>
  );
}

Object.assign(window, { TokensPanel });

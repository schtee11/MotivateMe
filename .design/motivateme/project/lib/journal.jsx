// journal.jsx — Journal screen (list + read + compose states)

const JOURNAL_ENTRIES = [
  {
    id: 'j1',
    date: new Date(Date.now() - 0),
    mood: 'good',
    title: 'Slow Tuesday',
    body: "Did the walk before coffee — that might be the trick. I kept thinking the day would start when I sat down at the desk, but really it started at the front door. Ten minutes in, the air was so clear I didn't want to come back inside.\n\nPush day later. Shoulder felt a little cranky last week so I'll drop to tier 2 and see.",
    prompt: "What's one small thing you're grateful for today?",
    grateful: 'Fresh cold air and no one emailing me yet.',
  },
  {
    id: 'j2',
    date: new Date(Date.now() - 86400000),
    mood: 'tired',
    title: 'Rest day, actually resting',
    body: "Slept 9 hours. Body says thank you. Took the dog out, cooked instead of ordered. Didn't earn the rest day, just took it, which the old version of me would've called lazy.",
    prompt: 'What did you do for yourself today?',
    grateful: 'Sleep. Just sleep.',
  },
  {
    id: 'j3',
    date: new Date(Date.now() - 2 * 86400000),
    mood: 'great',
    title: 'PR on deadlift',
    body: "185 for 3. A month ago that was a hard single. Form felt locked in — bar path clean, no butt-wink. Not going to chase a heavier one next week, going to bank this one and let it settle.",
    prompt: 'What made today feel good?',
    grateful: 'The slow, boring math of getting stronger.',
  },
  {
    id: 'j4',
    date: new Date(Date.now() - 4 * 86400000),
    mood: 'okay',
    title: '',
    body: "Short one. Missed the walk, did the stretching. Gave myself credit for the half I did instead of grading the half I missed.",
    prompt: 'How did today treat you?',
    grateful: null,
  },
  {
    id: 'j5',
    date: new Date(Date.now() - 6 * 86400000),
    mood: 'good',
    title: 'First week back',
    body: "Four out of seven. Last time I tried this I went too hard week one and flamed out by Thursday. This time I made the workouts shorter than I thought I needed. Turns out 'a little' every day feels way better than 'a lot' three times.",
    prompt: 'What did you learn this week?',
    grateful: 'Lower expectations. Higher consistency.',
  },
];

function JournalListScreen({ t, onOpen, onCompose, onBack, dayOne }) {
  if (dayOne && typeof JournalEmpty !== 'undefined') return <JournalEmpty t={t} onCompose={onCompose}/>;
  const grouped = React.useMemo(() => {
    const g = {};
    JOURNAL_ENTRIES.forEach(e => {
      const key = journalDayLabel(e.date);
      (g[key] ||= []).push(e);
    });
    return g;
  }, []);

  return (
    <>
      <div style={{ padding: '52px 16px 6px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{ border: 'none', background: 'transparent', cursor: 'pointer',
          display: 'flex', alignItems: 'center', gap: 2, padding: 4,
          fontFamily: t.family.text, fontSize: 17, color: t.color.primary }}>
          <Icon name="chevronLeft" size={22} color={t.color.primary} strokeWidth={2.4}/>
          <span>Today</span>
        </button>
        <button onClick={onCompose} style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 4 }}>
          <Icon name="pencil" size={22} color={t.color.primary}/>
        </button>
      </div>

      <div style={{ padding: '8px 20px 100px' }}>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, letterSpacing: -0.8 }}>
          Journal
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 4, marginBottom: 20 }}>
          {JOURNAL_ENTRIES.length} entries · {streakOfEntries()} day writing streak
        </div>

        {/* Today prompt card — if no entry today, nudge; if there is one, show it differently */}
        <TodayPromptCard t={t} onCompose={onCompose}/>

        {/* Entries grouped by date */}
        <div style={{ marginTop: 20 }}>
          {Object.entries(grouped).map(([label, entries]) => (
            <div key={label} style={{ marginBottom: 18 }}>
              <div style={{
                fontFamily: t.family.rounded, fontSize: 12, fontWeight: 700, letterSpacing: 0.8,
                textTransform: 'uppercase', color: t.color.textTertiary, padding: '0 4px 8px' }}>
                {label}
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {entries.map(e => <JournalCard key={e.id} t={t} entry={e} onClick={() => onOpen(e.id)}/>)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

function TodayPromptCard({ t, onCompose }) {
  return (
    <button onClick={onCompose} style={{
      width: '100%', textAlign: 'left', border: 'none', cursor: 'pointer',
      padding: 20, borderRadius: t.radius.cardLg,
      background: `linear-gradient(155deg, ${t.color.primaryTint}, ${t.color.surfaceCard} 80%)`,
      boxShadow: t.elev.sm, position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: -30, right: -30, width: 120, height: 120, borderRadius: '50%',
        background: `radial-gradient(circle, ${t.color.primary}1f, transparent 70%)` }}/>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
        <Icon name="sparkles" size={16} color={t.color.primary}/>
        <span style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
          textTransform: 'uppercase', color: t.color.primary }}>Today's prompt</span>
      </div>
      <div style={{
        fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
        fontSize: 22, lineHeight: '30px', fontStyle: 'italic',
        color: t.color.textPrimary, fontWeight: 400, letterSpacing: -0.2,
      }}>
        What's one small thing you're proud of from yesterday?
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 14,
        fontFamily: t.family.rounded, fontSize: 14, fontWeight: 600, color: t.color.primary }}>
        <span>Start writing</span>
        <Icon name="arrowRight" size={14} color={t.color.primary} strokeWidth={2.2}/>
      </div>
    </button>
  );
}

function JournalCard({ t, entry, onClick }) {
  const moodMeta = MOODS.find(m => m.k === entry.mood);
  return (
    <button onClick={onClick} style={{
      width: '100%', textAlign: 'left', border: 'none', cursor: 'pointer',
      padding: 16, borderRadius: t.radius.card,
      background: t.color.surfaceCard, boxShadow: t.elev.sm,
      display: 'flex', gap: 14, alignItems: 'flex-start',
    }}>
      <div style={{ width: 42, height: 42, borderRadius: 12, flexShrink: 0,
        background: t.color.primaryMuted,
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>
        {moodMeta?.emoji}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
          <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary,
            whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {entry.title || 'Untitled'}
          </span>
          <span style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary, flexShrink: 0 }}>
            {entry.date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}
          </span>
        </div>
        <div style={{
          fontFamily: `"New York", "Iowan Old Style", Georgia, serif`, fontSize: 14, lineHeight: '20px',
          color: t.color.textSecondary, marginTop: 4,
          display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden',
        }}>
          {entry.body}
        </div>
      </div>
    </button>
  );
}

function JournalReadScreen({ t, entryId, onBack, onEdit }) {
  const entry = JOURNAL_ENTRIES.find(e => e.id === entryId) || JOURNAL_ENTRIES[0];
  const moodMeta = MOODS.find(m => m.k === entry.mood);
  return (
    <>
      <div style={{ padding: '52px 16px 6px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{ border: 'none', background: 'transparent', cursor: 'pointer',
          display: 'flex', alignItems: 'center', gap: 2, padding: 4,
          fontFamily: t.family.text, fontSize: 17, color: t.color.primary }}>
          <Icon name="chevronLeft" size={22} color={t.color.primary} strokeWidth={2.4}/>
          <span>Journal</span>
        </button>
        <button onClick={onEdit} style={{ border: 'none', background: 'transparent', cursor: 'pointer', padding: 4,
          fontFamily: t.family.rounded, fontSize: 15, fontWeight: 600, color: t.color.primary }}>
          Edit
        </button>
      </div>

      <div style={{ padding: '12px 24px 100px', maxWidth: 560, margin: '0 auto' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 11, background: t.color.primaryMuted,
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>
            {moodMeta?.emoji}
          </div>
          <div>
            <div style={{ ...typeStyle(t.type.footnote, t.family), fontWeight: 600, color: t.color.textPrimary }}>
              {fullDateLabel(entry.date)}
            </div>
            <div style={{ ...typeStyle(t.type.caption1, t.family), color: t.color.textSecondary }}>
              Feeling {entry.mood} · {entry.date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}
            </div>
          </div>
        </div>

        {entry.title && (
          <div style={{
            fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
            fontSize: 30, lineHeight: '36px', fontWeight: 600, letterSpacing: -0.3,
            color: t.color.textPrimary, marginTop: 22,
          }}>
            {entry.title}
          </div>
        )}

        <div style={{
          fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
          fontSize: 18, lineHeight: '28px', color: t.color.textPrimary,
          marginTop: entry.title ? 14 : 22, whiteSpace: 'pre-wrap',
        }}>
          {entry.body}
        </div>

        {entry.grateful && (
          <div style={{
            marginTop: 24, padding: 18, borderRadius: t.radius.card,
            background: t.color.secondaryTint,
            display: 'flex', gap: 12,
          }}>
            <Icon name="leaf" size={18} color={t.color.secondary}/>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
                textTransform: 'uppercase', color: t.color.secondary, marginBottom: 4 }}>
                Grateful for
              </div>
              <div style={{
                fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
                fontSize: 16, lineHeight: '23px', fontStyle: 'italic', color: t.color.textPrimary }}>
                {entry.grateful}
              </div>
            </div>
          </div>
        )}

        <div style={{ marginTop: 28, display: 'flex', alignItems: 'center', gap: 8,
          ...typeStyle(t.type.caption1, t.family), color: t.color.textTertiary }}>
          <Icon name="clock" size={12} color={t.color.textTertiary} strokeWidth={1.8}/>
          <span>2 min read · kept on this device</span>
        </div>
      </div>
    </>
  );
}

function JournalComposeScreen({ t, onCancel, onSave }) {
  const [mood, setMood] = React.useState(null);
  const [title, setTitle] = React.useState('');
  const [body, setBody] = React.useState('');
  const [grateful, setGrateful] = React.useState('');
  const canSave = mood && (body.trim() || title.trim());

  return (
    <>
      <div style={{ padding: '52px 16px 6px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onCancel} style={{ border: 'none', background: 'transparent', cursor: 'pointer',
          fontFamily: t.family.text, fontSize: 17, color: t.color.primary, padding: 4 }}>
          Cancel
        </button>
        <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>New entry</span>
        <button onClick={canSave ? onSave : undefined} disabled={!canSave}
          style={{ border: 'none', background: 'transparent', cursor: canSave ? 'pointer' : 'default',
            fontFamily: t.family.rounded, fontSize: 17, fontWeight: 600,
            color: canSave ? t.color.primary : t.color.textTertiary, padding: 4 }}>
          Save
        </button>
      </div>

      <div style={{ padding: '10px 20px 100px' }}>
        <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
          {MOODS.map(m => {
            const sel = mood === m.k;
            return (
              <button key={m.k} onClick={() => setMood(m.k)} style={{
                flex: 1, padding: '10px 4px', borderRadius: 14, border: 'none',
                background: sel ? t.color.primaryMuted : t.color.surfaceInput,
                outline: sel ? `1.5px solid ${t.color.primary}` : 'none', outlineOffset: -1.5,
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                cursor: 'pointer',
                transform: sel ? 'translateY(-2px)' : 'translateY(0)',
                transition: 'all 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
              }}>
                <span style={{ fontSize: 20 }}>{m.emoji}</span>
                <span style={{ fontFamily: t.family.rounded, fontSize: 10, fontWeight: 600,
                  color: sel ? t.color.primary : t.color.textSecondary }}>{m.label}</span>
              </button>
            );
          })}
        </div>

        <input value={title} onChange={e => setTitle(e.target.value)} placeholder="Title (optional)" style={{
          width: '100%', border: 'none', outline: 'none', background: 'transparent',
          fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
          fontSize: 26, fontWeight: 600, color: t.color.textPrimary,
          padding: '6px 0 4px', boxSizing: 'border-box', letterSpacing: -0.3,
        }}/>

        <div style={{ height: 0.5, background: t.color.separator, margin: '6px 0 10px' }}/>

        <div style={{
          ...typeStyle(t.type.footnote, t.family), color: t.color.textTertiary,
          marginBottom: 6, fontStyle: 'italic',
        }}>
          Prompt · What's one small thing you're proud of from yesterday?
        </div>
        <textarea value={body} onChange={e => setBody(e.target.value)} placeholder="Start where you are…" style={{
          width: '100%', minHeight: 220, resize: 'none', border: 'none', outline: 'none',
          background: 'transparent', padding: 0, boxSizing: 'border-box',
          fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
          fontSize: 17, lineHeight: '26px', color: t.color.textPrimary,
        }}/>

        <div style={{ marginTop: 18, padding: 16, borderRadius: t.radius.card,
          background: t.color.secondaryTint }}>
          <div style={{ fontFamily: t.family.rounded, fontSize: 11, fontWeight: 700, letterSpacing: 0.5,
            textTransform: 'uppercase', color: t.color.secondary, marginBottom: 8 }}>
            One gratitude (optional)
          </div>
          <input value={grateful} onChange={e => setGrateful(e.target.value)}
            placeholder="Even small counts."
            style={{
              width: '100%', border: 'none', outline: 'none', background: 'transparent',
              fontFamily: `"New York", "Iowan Old Style", Georgia, serif`,
              fontSize: 16, fontStyle: 'italic', color: t.color.textPrimary, boxSizing: 'border-box',
            }}/>
        </div>

        {/* Compose toolbar — fake formatting + voice */}
        <div style={{
          position: 'sticky', bottom: 16, marginTop: 20,
          display: 'flex', alignItems: 'center', gap: 6, padding: 6,
          borderRadius: 9999, background: t.color.surfaceElevated, boxShadow: t.elev.md,
          width: 'fit-content', marginLeft: 'auto', marginRight: 'auto',
        }}>
          {['sparkles','mic','calendar','heart'].map((n, i) => (
            <button key={i} style={{ width: 38, height: 38, borderRadius: 9999, border: 'none',
              background: i === 0 ? t.color.primaryMuted : 'transparent', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name={n} size={18} color={i === 0 ? t.color.primary : t.color.textSecondary}/>
            </button>
          ))}
        </div>
      </div>
    </>
  );
}

// Helpers
function journalDayLabel(d) {
  const today = new Date(); today.setHours(0,0,0,0);
  const yest = new Date(today); yest.setDate(yest.getDate() - 1);
  const that = new Date(d); that.setHours(0,0,0,0);
  const diff = Math.round((today - that) / 86400000);
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Yesterday';
  if (diff < 7) return d.toLocaleDateString(undefined, { weekday: 'long' });
  return d.toLocaleDateString(undefined, { month: 'long', day: 'numeric' });
}
function fullDateLabel(d) {
  return d.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' });
}
function streakOfEntries() { return 6; }

Object.assign(window, {
  JournalListScreen, JournalReadScreen, JournalComposeScreen, JOURNAL_ENTRIES,
});

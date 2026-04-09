import { useState, FormEvent, ChangeEvent } from 'react';

interface TodoFormProps {
  onAdd: (text: string) => Promise<void>;
}

function TodoForm({ onAdd }: TodoFormProps) {
  const [text, setText] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    const trimmed = text.trim();
    if (!trimmed) return;

    setSubmitting(true);
    await onAdd(trimmed);
    setText('');
    setSubmitting(false);
  };

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setText(e.target.value);
  };

  return (
    <form className="todo-form" onSubmit={handleSubmit}>
      <input
        type="text"
        value={text}
        onChange={handleChange}
        placeholder="What needs to be done?"
        autoComplete="off"
        aria-label="New task input"
        disabled={submitting}
      />
      <button type="submit" className="btn btn-primary" disabled={submitting || !text.trim()}>
        Add
      </button>
    </form>
  );
}

export default TodoForm;

.PHONY: test help install clean scaffold

help:
	@echo "Todo CLI - Available commands:"
	@echo "  make test     - Run test suite"
	@echo "  make scaffold - Quick scaffold smoke test"
	@echo "  make install  - Create symlink to /usr/local/bin/todo (requires sudo)"
	@echo "  make clean    - Remove test data and backups"

test:
	@echo "Running Todo CLI scaffold tests..."
	@python3 test_scaffold.py

scaffold:
	@echo "Running scaffold smoke tests..."
	@python3 test_scaffold_basic.py

install:
	@echo "Installing todo.py to /usr/local/bin/todo..."
	@sudo ln -sf $(PWD)/todo.py /usr/local/bin/todo
	@echo "Done! Run 'todo help' to get started."

clean:
	@echo "Cleaning test data..."
	@rm -rf ~/.todo/
	@echo "Cleaned."

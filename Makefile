all: format build test

format:
	@cargo fmt --all
	@librocksdb_sys/crocksdb/format-diff.sh > /dev/null || true

build:
	@cargo build

test:
	@export RUST_BACKTRACE=1 && cargo test -- --nocapture

clean:
	@cargo clean
	@cd librocksdb_sys && cargo clean

# TODO it could be worth fixing some of these lints
clippy:
	@cargo clippy --all -- \
	-D warnings \
	-A clippy::redundant_field_names -A clippy::single_match \
	-A clippy::assign_op_pattern -A clippy::new_without_default -A clippy::useless_let_if_seq \
	-A clippy::needless_return -A clippy::len_zero

update_rocksdb:
	@if [ -n "${ROCKSDB_REPO}" ]; then \
		git config --file=.gitmodules submodule.rocksdb.url https://github.com/${ROCKSDB_REPO}/rocksdb.git; \
	fi
	@if [ -n "${ROCKSDB_BRANCH}" ]; then \
		git config --file=.gitmodules submodule.rocksdb.branch ${ROCKSDB_BRANCH}; \
	fi
	@git submodule sync
	@git submodule update --init --remote librocksdb_sys/rocksdb

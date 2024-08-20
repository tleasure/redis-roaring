#!/usr/bin/env bash

function configure_submodules()
{
  git submodule init
  git submodule update
  git submodule status
}
function amalgamate_croaring()
{
  pushd . 
  cd src 
  # generates header files
  ../deps/CRoaring/amalgamation.sh 
  popd
} 
function configure_keydb()
{
  pushd .
  cd deps/KeyDB
  git submodule init && git submodule update

  make
  popd
}
function configure_hiredis()
{
  cd deps/hiredis
  make
  cd -
}
function build()
{
  mkdir -p build
  cd build
  cmake ..
  make
  local LIB=$(find libredis-roaring*)
  
  cd ..
  mkdir -p dist
  cp "build/$LIB" dist
  cp deps/KeyDB/keydb.conf dist
  cp deps/KeyDB/src/{keydb-benchmark,keydb-check-aof,keydb-check-rdb,keydb-cli,keydb-sentinel,keydb-server} dist
  printf "\n\nloadmodule $(pwd)/dist/$LIB" >> dist/keydb.conf
}
function instructions()
{
  echo ""
  echo "Start KeyDB server with redis-roaring:"
  echo "./dist/keydb-server ./dist/keydb.conf"
  echo "Connect to server:"
  echo "./dist/keydb-cli"
}

configure_submodules
amalgamate_croaring
configure_keydb
configure_hiredis
build
instructions


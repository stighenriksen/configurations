{ nixpkgs ? import <nixpkgs> {} }:

nixpkgs.stdenv.mkDerivation rec {
  name = "hipadvisor";
  #src = ../../build/libs/hipadvisor-all.jar; # for local/dev testing...
  src = /var/lib/jenkins/jobs/hipadvisor_build_master/lastSuccessful/archive/hipadvisor.jar;
  meta = with nixpkgs.stdenv.lib; {
    description = "The hipadvisor server and frontend.";
    homepage = http://www.hipadvisor.com;
    platforms = platforms.all;
  };

  buildCommand = "ln -s $src $out";
}

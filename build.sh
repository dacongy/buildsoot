#!/bin/bash
set -e

# WARNING: assume GNU readlink
BUILD_ROOT=$(readlink -e $(dirname $0))
SOOT_DIR="${BUILD_ROOT}/soot"
JASMIN_DIR="${BUILD_ROOT}/jasmin"
HEROS_DIR="${BUILD_ROOT}/heros"

echo "==="
echo "BUILD_ROOT = ${BUILD_ROOT}"
echo "SOOT_DIR = ${SOOT_DIR}"
echo "JASMIN_DIR = ${JASMIN_DIR}"
echo "HEROS_DIR = ${HEROS_DIR}"
echo "==="

DEPS_DIR="${BUILD_ROOT}/deps"

if [[ ! -d ${DEPS_DIR} ]]; then
  mkdir -v ${DEPS_DIR}
fi

# Build jasmin
JASMIN_RELEASE_LOC=${JASMIN_RELEASE_LOC:-"${JASMIN_DIR}/lib"}
JASMIN_VERSION=${JASMIN_VERSION:-"2.2.1"}
JASMIN_JAVA_CUP_JAR=${JASMIN_JAVA_CUP_JAR:-"${JASMIN_DIR}/libs/java_cup.jar"}
JASMIN_JAR_TMP="${JASMIN_RELEASE_LOC}/jasminclasses-${JASMIN_VERSION}.jar"
JASMIN_JAR="${DEPS_DIR}/jasminclasses-${JASMIN_VERSION}.jar"

if [[ ! -f ${JASMIN_JAR} ]]; then
  ant \
    -Djava_cup.jar=${JASMIN_JAVA_CUP_JAR} \
    -Drelease.loc=${JASMIN_RELEASE_LOC} \
    -Djasmin.version=${JASMIN_VERSION} \
    -f jasmin/build.xml jasmin-jar
  if [[ -f ${JASMIN_JAR_TMP} ]]; then
    mv -v ${JASMIN_JAR_TMP} ${JASMIN_JAR}
  fi
  if [[ ! -f ${JASMIN_JAR} ]]; then
    echo "Cannot build jasmin jar. Abort."
    exit
  fi
fi

# Build heros
HEROS_VERSION="develop"
GUAVA_JAR="${HEROS_DIR}/guava-14.0.1.jar"
SLF4J_API_JAR=${SLF4J_API_JAR:-"${HEROS_DIR}/slf4j-api-1.7.5.jar"}
SLF4J_SIMPLE_JAR=${SLF4J_SIMPLE_JAR:-"${HEROS_DIR}/slf4j-simple-1.7.5.jar"}
HEROS_JAR_TMP="${HEROS_DIR}/heros-${HEROS_VERSION}.jar"
HEROS_JAR="${DEPS_DIR}/heros-${HEROS_VERSION}.jar"

if [[ ! -f ${HEROS_JAR} ]]; then
  ant \
    -Dheros.version=${HEROS_VERSION} \
    -Dguava.jar=${GUAVA_JAR} \
    -Dslf4j-api.jar=${SLF4J_API_JAR} \
    -Dslf4j-simple.jar=${SLF4J_SIMPLE_JAR} \
    -f ${HEROS_DIR}/build.xml jar
  if [[ -f ${HEROS_JAR_TMP} ]]; then
    mv -v ${HEROS_JAR_TMP} ${HEROS_JAR}
  fi
  if [[ ! -f ${HEROS_JAR} ]]; then
    echo "Cannot build heros jar. Abort."
    exit
  fi
fi

# Build soot
XML_PRINTER_JAR=${XML_PRINTER_JAR:-"${SOOT_DIR}/libs/AXMLPrinter2.jar"}
POLYGLOT_JAR=${POLYGLOT_JAR:-"${SOOT_DIR}/libs/polyglot.jar"}
BAKSMALI_JAR=${BAKSMALI_JAR:-"${SOOT_DIR}/libs/baksmali-1.3.2.jar"}
BAKSMALI2_JAR=${BAKSMALI2_JAR:-"${SOOT_DIR}/libs/baksmali-2.0b5.jar"}
SOOT_VERSION="develop"
SOOT_RELEASE_LOC=${SOOT_RELEASE_LOC:-"${SOOT_DIR}/lib"}
JAVAAPI_URL=${JAVAAPI_URL:-"http://java.sun.com/j2se/1.6.0/docs/api/"}
JUNIT_JAR=${JUNIT_JAR:-"${SOOT_DIR}/libs/junit-4.11.jar"}
HAMCREST_JAR=${HAMCREST_JAR:-"${SOOT_DIR}/libs/hamcrest-all-1.3.jar"}
SOOT_JAVACUP_JAR=${SOOT_JAVACUP_JAR:-"${SOOT_DIR}/libs/java_cup.jar"}

SOOT_JAR="${SOOT_RELEASE_LOC}/sootclasses-${SOOT_VERSION}.jar"

if [[ ! -f ${SOOT_JAR} ]]; then
  ant \
    -Dxmlprinter.jar=${XML_PRINTER_JAR} \
    -Dpolyglot.jar=${POLYGLOT_JAR} \
    -Dbaksmali.jar=${BAKSMALI_JAR} \
    -Dbaksmali2.jar=${BAKSMALI2_JAR} \
    -Dslf4j-api.jar=${SLF4J_API_JAR} \
    -Dslf4j-simple.jar=${SLF4J_SIMPLE_JAR} \
    -Djasmin.jar=${JASMIN_JAR} \
    -Dheros.jar=${HEROS_JAR} \
    -Dsoot.version=${SOOT_VERSION} \
    -Drelease.loc=${SOOT_RELEASE_LOC} \
    -Djavaapi.url=${JAVAAPI_URL} \
    -f soot/build.xml classesjar
  if [[ ! -f ${SOOT_JAR} ]]; then
    echo "Cannot build soot jar. Abort."
    exit
  fi
fi


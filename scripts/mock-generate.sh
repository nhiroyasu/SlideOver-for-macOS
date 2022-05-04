#!/usr/bin/env bash

set -ue

binary/mockolo -s ./slideover-for-macos -d ./slideover-for-macosTests/Mocks/mock.generated.swift --testable-imports Fixture_in_Picture --enable-args-history

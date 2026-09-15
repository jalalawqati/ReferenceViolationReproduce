# ReferenceViolationReproduce

Reproduces SQLiteData (1.12.0) deleting a child record locally when its parent's save failed with `quotaExceeded`.

## Setup

1. Change the bundle ID and the CloudKit container (`iCloud.com.ReferenceViolationReproduce`) to your own, in `ReferenceViolationReproduce.entitlements` and `ContentView.swift`.
2. Run on a device signed into an iCloud account whose storage is full.

## Steps

1. Tap **1. Add parent** until the console shows `quotaExceeded` for `parents` (each parent uploads 10 MB).
2. Tap **2. Add child to last parent**.

**Expected:** Children stays at 1.
**Actual:** the child fails with `referenceViolation` and is deleted locally; Children drops to 0.

**Delete everything in CloudKit** resets the data between runs.

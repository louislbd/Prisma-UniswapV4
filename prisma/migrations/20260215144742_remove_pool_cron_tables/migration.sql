/*
  Warnings:

  - You are about to drop the `PoolDayData` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `PoolHourData` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "PoolDayData" DROP CONSTRAINT "PoolDayData_poolId_fkey";

-- DropForeignKey
ALTER TABLE "PoolHourData" DROP CONSTRAINT "PoolHourData_poolId_fkey";

-- DropTable
DROP TABLE "PoolDayData";

-- DropTable
DROP TABLE "PoolHourData";

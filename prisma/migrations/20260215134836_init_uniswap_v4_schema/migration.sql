/*
  Warnings:

  - You are about to drop the `Post` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "ModificationType" AS ENUM ('MINT', 'BURN');

-- CreateEnum
CREATE TYPE "HookType" AS ENUM ('BEFORE_INITIALIZE', 'AFTER_INITIALIZE', 'BEFORE_ADD_LIQUIDITY', 'AFTER_ADD_LIQUIDITY', 'BEFORE_REMOVE_LIQUIDITY', 'AFTER_REMOVE_LIQUIDITY', 'BEFORE_SWAP', 'AFTER_SWAP', 'BEFORE_DONATE', 'AFTER_DONATE');

-- CreateEnum
CREATE TYPE "CampaignStatus" AS ENUM ('PENDING', 'ACTIVE', 'CALCULATING', 'DISTRIBUTING', 'COMPLETED', 'CANCELLED');

-- DropForeignKey
ALTER TABLE "Post" DROP CONSTRAINT "Post_authorId_fkey";

-- DropTable
DROP TABLE "Post";

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "Pool" (
    "id" TEXT NOT NULL,
    "token0" TEXT NOT NULL,
    "token1" TEXT NOT NULL,
    "fee" INTEGER NOT NULL,
    "tickSpacing" INTEGER NOT NULL,
    "hooks" TEXT NOT NULL,
    "sqrtPriceX96" TEXT NOT NULL,
    "tick" INTEGER NOT NULL,
    "liquidity" TEXT NOT NULL,
    "protocolFee0" INTEGER NOT NULL DEFAULT 0,
    "protocolFee1" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAtBlock" BIGINT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pool_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Position" (
    "id" TEXT NOT NULL,
    "poolId" TEXT NOT NULL,
    "owner" TEXT NOT NULL,
    "tickLower" INTEGER NOT NULL,
    "tickUpper" INTEGER NOT NULL,
    "salt" TEXT NOT NULL DEFAULT '0',
    "liquidity" TEXT NOT NULL,
    "tokensOwed0" TEXT NOT NULL DEFAULT '0',
    "tokensOwed1" TEXT NOT NULL DEFAULT '0',
    "feeGrowthInside0LastX128" TEXT NOT NULL DEFAULT '0',
    "feeGrowthInside1LastX128" TEXT NOT NULL DEFAULT '0',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAtBlock" BIGINT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "Position_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Swap" (
    "id" TEXT NOT NULL,
    "txHash" TEXT NOT NULL,
    "logIndex" INTEGER NOT NULL,
    "blockNumber" BIGINT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "poolId" TEXT NOT NULL,
    "sender" TEXT NOT NULL,
    "recipient" TEXT NOT NULL,
    "amount0" TEXT NOT NULL,
    "amount1" TEXT NOT NULL,
    "sqrtPriceX96" TEXT NOT NULL,
    "liquidity" TEXT NOT NULL,
    "tick" INTEGER NOT NULL,
    "fee0" TEXT NOT NULL DEFAULT '0',
    "fee1" TEXT NOT NULL DEFAULT '0',

    CONSTRAINT "Swap_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LiquidityModification" (
    "id" TEXT NOT NULL,
    "txHash" TEXT NOT NULL,
    "logIndex" INTEGER NOT NULL,
    "blockNumber" BIGINT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "poolId" TEXT NOT NULL,
    "positionId" TEXT,
    "owner" TEXT NOT NULL,
    "tickLower" INTEGER NOT NULL,
    "tickUpper" INTEGER NOT NULL,
    "liquidityDelta" TEXT NOT NULL,
    "amount0" TEXT NOT NULL,
    "amount1" TEXT NOT NULL,
    "type" "ModificationType" NOT NULL,

    CONSTRAINT "LiquidityModification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tick" (
    "poolId" TEXT NOT NULL,
    "tick" INTEGER NOT NULL,
    "liquidityGross" TEXT NOT NULL,
    "liquidityNet" TEXT NOT NULL,
    "feeGrowthOutside0X128" TEXT NOT NULL DEFAULT '0',
    "feeGrowthOutside1X128" TEXT NOT NULL DEFAULT '0',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Tick_pkey" PRIMARY KEY ("poolId","tick")
);

-- CreateTable
CREATE TABLE "HookCall" (
    "id" TEXT NOT NULL,
    "txHash" TEXT NOT NULL,
    "logIndex" INTEGER NOT NULL,
    "blockNumber" BIGINT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "poolId" TEXT NOT NULL,
    "hookAddress" TEXT NOT NULL,
    "hookType" "HookType" NOT NULL,
    "hookData" TEXT,
    "success" BOOLEAN NOT NULL,
    "gasUsed" INTEGER,

    CONSTRAINT "HookCall_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PoolHourData" (
    "id" TEXT NOT NULL,
    "poolId" TEXT NOT NULL,
    "hour" TIMESTAMP(3) NOT NULL,
    "open" TEXT NOT NULL,
    "high" TEXT NOT NULL,
    "low" TEXT NOT NULL,
    "close" TEXT NOT NULL,
    "volumeToken0" TEXT NOT NULL DEFAULT '0',
    "volumeToken1" TEXT NOT NULL DEFAULT '0',
    "volumeUSD" TEXT NOT NULL DEFAULT '0',
    "liquidityAvg" TEXT NOT NULL DEFAULT '0',
    "liquidityEnd" TEXT NOT NULL DEFAULT '0',
    "feesToken0" TEXT NOT NULL DEFAULT '0',
    "feesToken1" TEXT NOT NULL DEFAULT '0',
    "feesUSD" TEXT NOT NULL DEFAULT '0',
    "txCount" INTEGER NOT NULL DEFAULT 0,
    "swapCount" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "PoolHourData_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PoolDayData" (
    "id" TEXT NOT NULL,
    "poolId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "open" TEXT NOT NULL,
    "high" TEXT NOT NULL,
    "low" TEXT NOT NULL,
    "close" TEXT NOT NULL,
    "volumeToken0" TEXT NOT NULL DEFAULT '0',
    "volumeToken1" TEXT NOT NULL DEFAULT '0',
    "volumeUSD" TEXT NOT NULL DEFAULT '0',
    "tvlToken0" TEXT NOT NULL DEFAULT '0',
    "tvlToken1" TEXT NOT NULL DEFAULT '0',
    "tvlUSD" TEXT NOT NULL DEFAULT '0',
    "liquidityAvg" TEXT NOT NULL DEFAULT '0',
    "liquidityEnd" TEXT NOT NULL DEFAULT '0',
    "feesToken0" TEXT NOT NULL DEFAULT '0',
    "feesToken1" TEXT NOT NULL DEFAULT '0',
    "feesUSD" TEXT NOT NULL DEFAULT '0',
    "txCount" INTEGER NOT NULL DEFAULT 0,
    "swapCount" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "PoolDayData_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Campaign" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "poolId" TEXT NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3) NOT NULL,
    "rewardToken" TEXT NOT NULL,
    "totalRewards" TEXT NOT NULL,
    "alpha" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "beta" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "gamma" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "delta" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "minTickRange" INTEGER,
    "maxTickRange" INTEGER,
    "requiredHook" TEXT,
    "hookBonusMultiplier" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "status" "CampaignStatus" NOT NULL DEFAULT 'PENDING',
    "merkleRoot" TEXT,
    "merkleTreeIpfs" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdBy" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Campaign_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CampaignEpoch" (
    "id" TEXT NOT NULL,
    "campaignId" TEXT NOT NULL,
    "epochNumber" INTEGER NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3) NOT NULL,
    "snapshotBlock" BIGINT NOT NULL,
    "totalScore" TEXT NOT NULL,
    "merkleRoot" TEXT,
    "merkleTreeIpfs" TEXT,
    "calculated" BOOLEAN NOT NULL DEFAULT false,
    "distributedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CampaignEpoch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RewardDistribution" (
    "id" TEXT NOT NULL,
    "campaignId" TEXT NOT NULL,
    "epochId" TEXT,
    "positionId" TEXT NOT NULL,
    "userAddress" TEXT NOT NULL,
    "timeWeightedLiquidity" TEXT NOT NULL,
    "feesGenerated" TEXT NOT NULL,
    "concentrationFactor" DOUBLE PRECISION NOT NULL,
    "balanceFactor" DOUBLE PRECISION NOT NULL,
    "hookBonus" DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    "score" TEXT NOT NULL,
    "rewardAmount" TEXT NOT NULL,
    "claimed" BOOLEAN NOT NULL DEFAULT false,
    "claimedAt" TIMESTAMP(3),
    "claimTxHash" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RewardDistribution_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PositionSnapshot" (
    "id" TEXT NOT NULL,
    "positionId" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "blockNumber" BIGINT NOT NULL,
    "liquidity" TEXT NOT NULL,
    "tickLower" INTEGER NOT NULL,
    "tickUpper" INTEGER NOT NULL,
    "poolSqrtPriceX96" TEXT NOT NULL,
    "poolTick" INTEGER NOT NULL,
    "inRange" BOOLEAN NOT NULL,
    "feesEarned0" TEXT NOT NULL DEFAULT '0',
    "feesEarned1" TEXT NOT NULL DEFAULT '0',

    CONSTRAINT "PositionSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Token" (
    "address" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "decimals" INTEGER NOT NULL,
    "priceUSD" TEXT NOT NULL DEFAULT '0',
    "priceUpdatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Token_pkey" PRIMARY KEY ("address")
);

-- CreateTable
CREATE TABLE "IndexerState" (
    "id" TEXT NOT NULL DEFAULT 'singleton',
    "lastIndexedBlock" BIGINT NOT NULL,
    "lastIndexedTimestamp" TIMESTAMP(3) NOT NULL,
    "chainId" INTEGER NOT NULL,
    "isSyncing" BOOLEAN NOT NULL DEFAULT false,
    "syncStartedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "IndexerState_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Pool_token0_token1_idx" ON "Pool"("token0", "token1");

-- CreateIndex
CREATE INDEX "Pool_hooks_idx" ON "Pool"("hooks");

-- CreateIndex
CREATE INDEX "Pool_createdAt_idx" ON "Pool"("createdAt");

-- CreateIndex
CREATE INDEX "Position_poolId_idx" ON "Position"("poolId");

-- CreateIndex
CREATE INDEX "Position_owner_idx" ON "Position"("owner");

-- CreateIndex
CREATE INDEX "Position_poolId_owner_idx" ON "Position"("poolId", "owner");

-- CreateIndex
CREATE INDEX "Position_createdAt_idx" ON "Position"("createdAt");

-- CreateIndex
CREATE INDEX "Swap_poolId_idx" ON "Swap"("poolId");

-- CreateIndex
CREATE INDEX "Swap_timestamp_idx" ON "Swap"("timestamp");

-- CreateIndex
CREATE INDEX "Swap_blockNumber_idx" ON "Swap"("blockNumber");

-- CreateIndex
CREATE INDEX "Swap_sender_idx" ON "Swap"("sender");

-- CreateIndex
CREATE INDEX "Swap_poolId_timestamp_idx" ON "Swap"("poolId", "timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "Swap_txHash_logIndex_key" ON "Swap"("txHash", "logIndex");

-- CreateIndex
CREATE INDEX "LiquidityModification_poolId_idx" ON "LiquidityModification"("poolId");

-- CreateIndex
CREATE INDEX "LiquidityModification_positionId_idx" ON "LiquidityModification"("positionId");

-- CreateIndex
CREATE INDEX "LiquidityModification_owner_idx" ON "LiquidityModification"("owner");

-- CreateIndex
CREATE INDEX "LiquidityModification_timestamp_idx" ON "LiquidityModification"("timestamp");

-- CreateIndex
CREATE INDEX "LiquidityModification_poolId_timestamp_idx" ON "LiquidityModification"("poolId", "timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "LiquidityModification_txHash_logIndex_key" ON "LiquidityModification"("txHash", "logIndex");

-- CreateIndex
CREATE INDEX "Tick_poolId_idx" ON "Tick"("poolId");

-- CreateIndex
CREATE INDEX "HookCall_poolId_idx" ON "HookCall"("poolId");

-- CreateIndex
CREATE INDEX "HookCall_hookAddress_idx" ON "HookCall"("hookAddress");

-- CreateIndex
CREATE INDEX "HookCall_hookType_idx" ON "HookCall"("hookType");

-- CreateIndex
CREATE INDEX "HookCall_timestamp_idx" ON "HookCall"("timestamp");

-- CreateIndex
CREATE INDEX "HookCall_poolId_hookAddress_idx" ON "HookCall"("poolId", "hookAddress");

-- CreateIndex
CREATE UNIQUE INDEX "HookCall_txHash_logIndex_key" ON "HookCall"("txHash", "logIndex");

-- CreateIndex
CREATE INDEX "PoolHourData_hour_idx" ON "PoolHourData"("hour");

-- CreateIndex
CREATE INDEX "PoolHourData_poolId_hour_idx" ON "PoolHourData"("poolId", "hour");

-- CreateIndex
CREATE UNIQUE INDEX "PoolHourData_poolId_hour_key" ON "PoolHourData"("poolId", "hour");

-- CreateIndex
CREATE INDEX "PoolDayData_date_idx" ON "PoolDayData"("date");

-- CreateIndex
CREATE INDEX "PoolDayData_poolId_date_idx" ON "PoolDayData"("poolId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "PoolDayData_poolId_date_key" ON "PoolDayData"("poolId", "date");

-- CreateIndex
CREATE INDEX "Campaign_poolId_idx" ON "Campaign"("poolId");

-- CreateIndex
CREATE INDEX "Campaign_status_idx" ON "Campaign"("status");

-- CreateIndex
CREATE INDEX "Campaign_startTime_endTime_idx" ON "Campaign"("startTime", "endTime");

-- CreateIndex
CREATE INDEX "CampaignEpoch_campaignId_idx" ON "CampaignEpoch"("campaignId");

-- CreateIndex
CREATE UNIQUE INDEX "CampaignEpoch_campaignId_epochNumber_key" ON "CampaignEpoch"("campaignId", "epochNumber");

-- CreateIndex
CREATE INDEX "RewardDistribution_campaignId_idx" ON "RewardDistribution"("campaignId");

-- CreateIndex
CREATE INDEX "RewardDistribution_userAddress_idx" ON "RewardDistribution"("userAddress");

-- CreateIndex
CREATE INDEX "RewardDistribution_claimed_idx" ON "RewardDistribution"("claimed");

-- CreateIndex
CREATE INDEX "RewardDistribution_userAddress_campaignId_idx" ON "RewardDistribution"("userAddress", "campaignId");

-- CreateIndex
CREATE UNIQUE INDEX "RewardDistribution_campaignId_epochId_positionId_key" ON "RewardDistribution"("campaignId", "epochId", "positionId");

-- CreateIndex
CREATE INDEX "PositionSnapshot_positionId_idx" ON "PositionSnapshot"("positionId");

-- CreateIndex
CREATE INDEX "PositionSnapshot_timestamp_idx" ON "PositionSnapshot"("timestamp");

-- CreateIndex
CREATE INDEX "PositionSnapshot_positionId_timestamp_idx" ON "PositionSnapshot"("positionId", "timestamp");

-- CreateIndex
CREATE INDEX "Token_symbol_idx" ON "Token"("symbol");

-- AddForeignKey
ALTER TABLE "Position" ADD CONSTRAINT "Position_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Swap" ADD CONSTRAINT "Swap_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LiquidityModification" ADD CONSTRAINT "LiquidityModification_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LiquidityModification" ADD CONSTRAINT "LiquidityModification_positionId_fkey" FOREIGN KEY ("positionId") REFERENCES "Position"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Tick" ADD CONSTRAINT "Tick_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HookCall" ADD CONSTRAINT "HookCall_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PoolHourData" ADD CONSTRAINT "PoolHourData_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PoolDayData" ADD CONSTRAINT "PoolDayData_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Campaign" ADD CONSTRAINT "Campaign_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "Pool"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CampaignEpoch" ADD CONSTRAINT "CampaignEpoch_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RewardDistribution" ADD CONSTRAINT "RewardDistribution_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RewardDistribution" ADD CONSTRAINT "RewardDistribution_epochId_fkey" FOREIGN KEY ("epochId") REFERENCES "CampaignEpoch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RewardDistribution" ADD CONSTRAINT "RewardDistribution_positionId_fkey" FOREIGN KEY ("positionId") REFERENCES "Position"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PositionSnapshot" ADD CONSTRAINT "PositionSnapshot_positionId_fkey" FOREIGN KEY ("positionId") REFERENCES "Position"("id") ON DELETE CASCADE ON UPDATE CASCADE;
